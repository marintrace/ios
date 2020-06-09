//
//  ProfileViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import Firebase

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
        do {
            try Auth.auth().signOut()
            
            //go to log in
            let story = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = story.instantiateViewController(withIdentifier: "LoginTableViewController") as? UINavigationController
            homeVC!.modalPresentationStyle = .fullScreen
            UIApplication.shared.windows.first?.rootViewController = homeVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } catch let signOutError as NSError {
            //todo - handle error
            print(signOutError)
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
