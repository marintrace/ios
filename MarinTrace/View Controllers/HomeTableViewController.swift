//
//  HomeTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import CoreLocation

class HomeTableViewController: UITableViewController, CLLocationManagerDelegate {

    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser()
        configViewsForUser()
        setupTableView()
        locManager.delegate = self
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
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "toLogin", sender: self)
        } else {
            //user exists, get details
            User.getDetails()
            
            //ask to send notifications (check if asked before too)
            askForNotification()
        }
    }
    
    func askForNotification() {
        
        //timed notifications work, but location doesnt for some reason
        
        //if haven't already asked before, prompt
        if true /*!UserDefaults.standard.bool(forKey: "asked_for_notification")*/ {
            let alert = UIAlertController(title: "Enable Reminder?", message: "Would you like us to send you a reminder to report symptoms when you arrive at school. We'll also send one reminding you to report contacts when you leave. If you say yes, make sure to accept the next prompts.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
                UserDefaults.standard.set(true, forKey: "asked_for_notification") //remember their choice
            }))
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: .alert) { (granted, error) in //request authorization
                    if error == nil && granted { //if user accepted
                        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse { //already authorized, request
                            NotificationScheduler.scheduleNotifications()
                        } else {
                            self.locManager.requestWhenInUseAuthorization() //ask
                        }
                    }
                }
                UserDefaults.standard.set(true, forKey: "asked_for_notification") //remember their choice
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request)
            }
        })
        
    }

    @IBAction func reportPositiveTest(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Reporting a positive test cannot be undone and will notify the school immediately.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
            self.showSpinner(onView: self.view)
            DataService.notifyRisk(criteria: ["Positive Test"]) { (error) in
                self.removeSpinner()
                if error != nil {
                    AlertHelperFunctions.presentAlertOnVC(title: "Error", message: error!.localizedDescription, vc: self)
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
    
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //user responded to prompt, if accepted show notifications
        if status == .authorizedWhenInUse {
            NotificationScheduler.scheduleNotifications()
        }
    }

}
