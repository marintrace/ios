//
//  HomeTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import CoreLocation

class HomeTableViewController: UITableViewController {

    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var statusCardButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser()
        setupTableView()
        configViewsForUser()
    }
    
    func setupTableView() {
        //hide hairline and dont allow selection
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = false
    }
    
    func configViewsForUser() {
        //hide certain sections
        tableView.reloadData()
        
        //configure image to be ma or branson, set nav bar title
        if User.school == .MA {
            let image = UIImage(named: "profile_ma")?.withRenderingMode(.alwaysOriginal)
            profileButton.setBackgroundImage(image, for: .normal, barMetrics: .default)
            self.title = "MA Trace"
        } else {
            let image = UIImage(named: "profile_branson")?.withRenderingMode(.alwaysOriginal)
            profileButton.setBackgroundImage(image, for: .normal, barMetrics: .default)
            self.title = "Branson Trace"
        }
        
        //round font
        profileButton.setTitleTextAttributes([NSAttributedString.Key.font:FontHelper.roundedFont(ofSize: 17, weight: .medium)], for: .normal)
        
        //setup text
        profileButton.title = User.initials
        profileButton.tintColor = .white
        
        //setup card color
        statusCardButton.tintColor = Colors.colorFor(forSchool: User.school)
    }
    
    //if no signed in user, go to login
    func checkUser() {
        guard credentialsManager.hasValid() else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLogin", sender: self)
            }
            return
        }
        
        //check if they've agreed to privacy policy
        if !UserDefaults.standard.bool(forKey: "agreed") {
            //show it
            let story = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = story.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as? UINavigationController
            homeVC!.modalPresentationStyle = .fullScreen
            UIApplication.shared.windows.first?.rootViewController = homeVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        
        //user exists, get details
        SpinnerHelper.show()
        User.getDetails { (success) in
            SpinnerHelper.hide()
            if success {
                DispatchQueue.main.async {
                    self.configViewsForUser()
                }
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toLogin", sender: self)
                    AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't load user details. If this error persists please contact us.")
                }
            }
        }
        
        //ask to send notifications (check if asked before too)
        askForNotification()
        
        //async reqeust to check + alert if not allowed on campus
        checkIfAllowed()
    }
    
    func askForNotification() {
        //if haven't already asked before, prompt
        if !UserDefaults.standard.bool(forKey: "asked_for_notification") {
            let alert = UIAlertController(title: "Enable Symptoms Reminder?", message: "Would you like us to send you a reminder to report symptoms before you get to school?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
                UserDefaults.standard.set(true, forKey: "asked_for_notification") //remember their choice
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: .alert) { (granted, error) in //request authorization
                    if error == nil && granted { //if user accepted
                        //schedule first set of notifications
                        NotificationScheduler.scheduleNotifications()
                    }
                }
                UserDefaults.standard.set(true, forKey: "asked_for_notification") //remember their choice
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func reportNegativeTest(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Reporting a NEGATIVE test cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
            SpinnerHelper.show()
            DataService.reportTest(testType: .negative) { (error) in
                SpinnerHelper.hide()
                if error != nil {
                    AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't report test result: " + error!.swaggerError + " If this error persists please contact us and contact the school to report the test result manually.")
                } else {
                    //backup
                    let rawReport = RawReports()
                    let testReport = TestReport()
                    testReport.type = "negative"
                    rawReport.testReport = testReport
                    RealmHelper.logItem(data: "Reported negative test", rawReport: rawReport)
                    
                    AlertHelperFunctions.presentAlert(title: "Success", message: "Your test was reported")
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func reportPositiveTest(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Reporting a POSITIVE test cannot be undone and will notify the school immediately.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
            SpinnerHelper.show()
            DataService.reportTest(testType: .positive) { (error) in
                SpinnerHelper.hide()
                if error != nil {
                    AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't report test result: " + error!.swaggerError + " If this error persists please contact us and contact the school to report the test result manually.")
                } else {
                    //backup
                    let rawReport = RawReports()
                    let testReport = TestReport()
                    testReport.type = "positive"
                    rawReport.testReport = testReport
                    RealmHelper.logItem(data: "Reported positive test", rawReport: rawReport)
                    
                    AlertHelperFunctions.presentAlert(title: "Success", message: "Your test was reported")
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func viewPrivacyPolicy(_ sender: Any) {
        self.showSafariViewController(url: "https://marintracingapp.org/privacy.html")
    }
    @IBAction func viewSecurityPrecautions(_ sender: Any) {
        self.showSafariViewController(url: "https://marintracingapp.org/security.html")
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        
    }
    
    @IBAction func tappedOpenQuestionnaire(_ sender: Any) {
        //see if they've already reported today
        guard let submitted = RealmHelper.alreadySubmittedQuestionnaireToday() else {return /*don't do anything, error will be presented by realm service*/}
        if submitted {
            AlertHelperFunctions.presentAlert(title: "Already Submitted", message: "You have already submitted your questionnaire today. If you need to make a change, contact your school.")
        } else {
            self.performSegue(withIdentifier: "showDailyReport", sender: self)
        }
    }
    
    //check in background if they are not allowed on campus
    func checkIfAllowed() {
        DataService.getUserStatus { (entryItem, _) in
            guard let entry = entryItem, let location = entryItem?.location else {return}
            
            //not allowed due to location
            if !entry.entry && entry.reason == .location {
                AlertHelperFunctions.presentAlert(title: "You are not allowed on campus", message: "You are currently \(location.location?.rawValue ?? "[LOCATION UNKNOWN]")")
            }
        }
    }
    
    // MARK: - Table view data source
    
    //config sections for each school
    private func sectionShouldBeHidden(_ section: Int) -> Bool {
        switch User.school {
        case .MA:
            switch section {
            //case 0, 1, 2, 3: return true
            default: return false //hide nothing
            }
        case .Branson:
            switch section {
            case 2: return true //hide testing
            default: return false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionShouldBeHidden(section) { //hide some sections depending on school
            return 0
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section) // Use the default number of rows for other sections
        }
    }
    
    //these functions create the spacing between the sectios
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionShouldBeHidden(section) { //hide some sections depending on school
            return CGFloat.leastNormalMagnitude
        } else {
            return 25
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionShouldBeHidden(section) { //hide some sections depending on school
            return nil
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
            return view
        }
    }
}
