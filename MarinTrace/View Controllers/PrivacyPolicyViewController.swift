//
//  PrivacyPolicyViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 9/18/20.
//  Copyright © 2020 The MarinTrace Foundation. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //give context
        AlertHelperFunctions.presentAlert(title: "Please Read and Accept the Privacy Policy and Terms of Service", message: "Before continuing, you must accept these terms.")
        
        //load
        let url = URL(string: "https://marintracingapp.org/privacy.html")
        let request = URLRequest(url: url!)
        webView.load(request)
    }

    @IBAction func agreeTapped(_ sender: Any) {
        //save choice
        UserDefaults.standard.set(true, forKey: "agreed")
        
        DataService.logMessage(message: "accepted privacy policy")
        
        //go home
        let story = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = story.instantiateViewController(withIdentifier: "HomeTableViewController") as? UINavigationController
        homeVC!.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController = homeVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
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
