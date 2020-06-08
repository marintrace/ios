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
        goToLogin()
        //try! Auth.auth().signOut()
        setupProfile()
        setupTableView()
    }
    
    func setupTableView() {
        //hide hairline and dont allow selection
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = false
    }
    
    func setupProfile() {
        
        //todo - configure image to be ma or branson
        let image = UIImage(named: "profile_ma")?.withRenderingMode(.alwaysOriginal)
        profileButton.setBackgroundImage(image, for: .normal, barMetrics: .default)
        
        guard let user = Auth.auth().currentUser else {return}
        guard let name = user.displayName else {return}
        let namesSplit = name.components(separatedBy: " ") //split into first and last
        if namesSplit.count > 1 { //if first and last name, use initials, else just use first initial
            let firstName = namesSplit[0]
            let lastName = namesSplit[1]
            profileButton.title = String(firstName[firstName.startIndex]) + String(lastName[lastName.startIndex])
        } else {
            let firstName = namesSplit[0]
            profileButton.title = String(firstName[firstName.startIndex])
        }
        
        profileButton.tintColor = .white
        
    }
    
    //if no signed in user, go to login
    func goToLogin() {
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "toLogin", sender: self)
        }
    }

    @IBAction func reportPositiveTest(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Reporting a positive test cannot be undone and will notify the school immediately.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { (_) in
            //report positive test
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
