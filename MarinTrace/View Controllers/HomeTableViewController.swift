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

class HomeTableViewController: UITableViewController {

    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUser()
        setupProfile()
        setupTableView()
                
    }
    
    func setupTableView() {
        //hide hairline and dont allow selection
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = false
    }
    
    func setupProfile() {
        //configure image to be ma or branson
        if User.school == .MA {
            let image = UIImage(named: "profile_ma")?.withRenderingMode(.alwaysOriginal)
            profileButton.setBackgroundImage(image, for: .normal, barMetrics: .default)
        } else {
            let image = UIImage(named: "profile_branson")?.withRenderingMode(.alwaysOriginal)
            profileButton.setBackgroundImage(image, for: .normal, barMetrics: .default)
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
        }
    }

    @IBAction func reportPositiveTest(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Reporting a positive test cannot be undone and will notify the school immediately.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
            DataService.notifyRisk(criteria: ["Positive Test"]) { (error) in
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

}
