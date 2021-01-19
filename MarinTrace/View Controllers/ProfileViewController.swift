//
//  ProfileViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import Auth0
import RealmSwift

class ProfileViewController: UIViewController {

    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var labelImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    func setupViews() {
        //configure image to be ma or branson
        if User.school == .MA {
            labelImage.image = UIImage(named: "profile_ma")
        } else {
            labelImage.image = UIImage(named: "profile_branson")
        }
        
        //round text
        initialLabel.font = FontHelper.roundedFont(ofSize: 29, weight: .medium)
        
        nameLabel.text = User.fullName
        initialLabel.text = User.initials
    }
    
    @IBAction func signOut(_ sender: Any) {
        DataService.logMessage(message: "logging out")
        
        //clear cache
        URLCache.shared.removeAllCachedResponses()
        
        SpinnerHelper.show()
        Auth0.webAuth().clearSession(federated:false) {
            SpinnerHelper.hide()
            switch $0 {
                case true:
                    DataService.logMessage(message: "logged out successfully")
                    
                    //clear creds
                    credentialsManager.revoke { (_) in
                    }
                    credentialsManager.clear()
                    
                    //clear realm
                    do {
                        try FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
                    } catch let error as NSError {
                        AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't clear local backups: \(error.localizedDescription). If this error persists please contact us.")
                    }
                    
                    //clear preferences/policy agreement
                    UserDefaults.standard.set(false, forKey: "asked_for_notification")
                    UserDefaults.standard.set(false, forKey: "agreed")
                    
                    //go to log in
                    DispatchQueue.main.async {
                        let story = UIStoryboard(name: "Main", bundle: nil)
                        let homeVC = story.instantiateViewController(withIdentifier: "LoginTableViewController") as? UINavigationController
                        homeVC!.modalPresentationStyle = .fullScreen
                        UIApplication.shared.windows.first?.rootViewController = homeVC
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                case false:
                    DataService.logMessage(message: "logout failed")
                    AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't log out. This is likely because you hit \"cancel.\" If this error persists please contact us.")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
