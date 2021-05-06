//
//  LoginTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import Auth0
import FirebaseAnalytics

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
        login(connection: "google-oauth2")
    }
    
    @IBAction func maLogIn(_ sender: Any) {
        login(connection: "google-oauth2")
    }
    
    @IBAction func headlandsLogIn(_ sender: Any) {
        login(connection: "MT-Email-Pass")
    }
    
    @IBAction func tildenLogin(_ sender: Any) {
        login(connection: "MT-Email-Pass")
    }
    
    //login, but refresh token because if they're signing up the first  token returned won't have their school role
    func login(connection: String) {
        DataService.logMessage(message: "starting login")
        Auth0.webAuth().scope("openid profile email offline_access").audience("tracing-rest-api").connection(connection)
            .start {
            switch $0 {
            case .failure(let error):
                DataService.logMessage(message: "login failed")
                DispatchQueue.main.async {
                    AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't login: "  + error.localizedDescription  + ". This may because you aren't using an @ma.org or @branson.org email account. If this error persists please contact us.")
                    DataService.logError(error: error)
                }
            case .success(let credentials):
                DataService.logMessage(message: "login succeeded")
                let stored = credentialsManager.store(credentials: credentials)
                DataService.logMessage(message: "stored credentials?: \(stored)")
                Analytics.logEvent(AnalyticsEventLogin, parameters: nil)

                DispatchQueue.main.async {
                    SpinnerHelper.show()
                    DataService.markUserAsActive { (apiError) in
                        
                        if apiError == nil {
                            SpinnerHelper.hide()
                            self.transitionOrError(error: nil)
                            return
                        }
                        
                        DataService.logMessage(message: "new user without roles")
                        
                        if let refreshToken = credentials.refreshToken {
                            DataService.logMessage(message: "refreshing token to get roles")
                            Auth0.authentication().renew(withRefreshToken: refreshToken).start { (result) in
                                switch(result) {
                                case .success(let credentials2):
                                    Analytics.logEvent(AnalyticsEventSignUp, parameters: nil)
                                    DataService.logMessage(message: "refreshing succeeded, marking as active")
                                    let stored2 = credentialsManager.store(credentials: credentials2)
                                    DataService.logMessage(message: "stored credentials?: \(stored2)")
                                    DataService.markUserAsActive { (apiError2) in
                                        SpinnerHelper.hide()
                                        DispatchQueue.main.async {
                                            self.transitionOrError(error: nil)
                                        }
                                    }
                                case .failure(let error):
                                    DataService.logMessage(message: "failed refreshing token to get roles")
                                    SpinnerHelper.hide()
                                    DispatchQueue.main.async {
                                        AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't login: "  + error.localizedDescription  + ". This may because you aren't using an @ma.org or @branson.org email account. If this error persists please contact us.")
                                        DataService.logError(error: error)
                                    }
                                }
                            }
                        } else {
                            DataService.logMessage(message: "failed to get refresh token")
                            SpinnerHelper.hide()
                            AlertHelperFunctions.presentAlert(title: "Error", message: "Could not verify authentication status. If this error persists please contact us.")
                        }
                    }
                }                
            }
        }
    }
    
    //separating this code because it could be called in two places due to need to double complete auth
    func transitionOrError(error:Error?) {
        if let activeError = error {
            AlertHelperFunctions.presentAlert(title: "Error", message: "Could not register your account with the server: " + activeError.swaggerError + " If this error persists please contact us.")
        } else {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = story.instantiateViewController(withIdentifier: "HomeTableViewController") as? UINavigationController
            homeVC!.modalPresentationStyle = .fullScreen
            UIApplication.shared.windows.first?.rootViewController = homeVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
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
