//
//  LoginTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import Auth0

class LoginTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = false
                
    }

    //MARK: IBActions
    @IBAction func bransonLogIn(_ sender: Any) {
        login()
    }
    
    @IBAction func maLogIn(_ sender: Any) {
        login()
    }
    
    func login() {
        Auth0.webAuth().scope("openid profile email").audience("tracing-rest-api")
            .start {
            switch $0 {
            case .failure(let error):
                DispatchQueue.main.async {
                    AlertHelperFunctions.presentAlertOnVC(title: "Error", message: "Couldn't login: "  + error.localizedDescription  + ". This may because you aren't using an @ma.org or @branson.org email account. If this error persists please contact us.", vc: self)
                    DataService.logError(error: error)
                }
            case .success(let credentials):
                credentialsManager.store(credentials: credentials)

                DispatchQueue.main.async {
                    SpinnerHelper.show()
                    DataService.markUserAsActive { (error) in
                        SpinnerHelper.hide()
                        if let activeError = error {
                            AlertHelperFunctions.presentAlertOnVC(title: "Error", message: "Could not register your account with the server: " + activeError.localizedDescription + " If this error persists please contact us.", vc: self)
                        } else {
                            let story = UIStoryboard(name: "Main", bundle: nil)
                            let homeVC = story.instantiateViewController(withIdentifier: "HomeTableViewController") as? UINavigationController
                            homeVC!.modalPresentationStyle = .fullScreen
                            UIApplication.shared.windows.first?.rootViewController = homeVC
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        }
                    }
                }                
            }
        }
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
