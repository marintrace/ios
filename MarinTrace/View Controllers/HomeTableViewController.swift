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
    }
    
    //if no signed in user, go to login
    func checkUser() {
        guard credentialsManager.hasValid() else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toLogin", sender: self)
            }
            return
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
                    AlertHelperFunctions.presentAlertOnVC(title: "Error", message: "Couldn't load user details. If this error persists please contact us." , vc: self)
                }
            }
        }
        
        //ask to send notifications (check if asked before too)
        askForNotification()
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
                    AlertHelperFunctions.presentAlertOnVC(title: "Error", message: "Couldn't report test result: " + error!.localizedDescription + " If this error persists please contact us and contact the school to report the test result manually." , vc: self)
                } else {
                    AlertHelperFunctions.presentAlertOnVC(title: "Success", message: "Your test was reported", vc: self)
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
                    AlertHelperFunctions.presentAlertOnVC(title: "Error", message: "Couldn't report test result: " + error!.localizedDescription + " If this error persists please contact us and contact the school to report the test result manually." , vc: self)
                } else {
                    AlertHelperFunctions.presentAlertOnVC(title: "Success", message: "Your test was reported", vc: self)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        
    }
    
    // MARK: - Table view data source
    //these functions create the spacing between the sectios
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        return view
    }
    
}
