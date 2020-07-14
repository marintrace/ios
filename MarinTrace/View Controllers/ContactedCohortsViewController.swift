//
//  ContactedCohortsViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import SwaggerClient

class ContactedCohortsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cohortTableView: UITableView!
    
    var contacts = [Contact]() //a list of the people they've contacted
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup table view
        cohortTableView.dataSource = self
        cohortTableView.delegate = self
            
    }
    
    @IBAction func reportContacts(_ sender: Any) {
        
        if contacts.count > 0 {
            //process contacts into ids
            let targets = contacts.map({$0.email})
            showSpinner(onView: self.view)
            DataService.reportInteractions(targetIDS: targets) { (error) in
                self.removeSpinner()
                if error != nil {
                    AlertHelperFunctions.presentAlertOnVC(title: "Error", message: error!.localizedDescription, vc: self)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            AlertHelperFunctions.presentAlertOnVC(title: "Error", message: "You must add at least one contact.", vc: self)
        }
    }
    
    //MARK: Table View Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cohortTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = contact.firstName + " " + contact.lastName
        return cell
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
