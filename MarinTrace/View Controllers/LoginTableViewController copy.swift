//
//  LoginTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = false
        
        //google auth
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
    }

    //MARK: IBActions
    @IBAction func bransonLogIn(_ sender: Any) {
        self.showSpinner(onView: self.view)
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func maLogIn(_ sender: Any) {
        self.showSpinner(onView: self.view)
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    // MARK: - Table view data source    
    //these functions create the spacing between the sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        return view
    }

}
