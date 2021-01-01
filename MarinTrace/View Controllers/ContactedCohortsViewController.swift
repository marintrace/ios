//
//  ContactedCohortsViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import SwaggerClient
import RealmSwift

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
            SpinnerHelper.show()
            DataService.reportInteractions(targetIDS: targets) { (error) in
                SpinnerHelper.hide()
                if error != nil {
                    AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't report contacts: " + error!.swaggerError + " If this error persists please contact us and contact your school to report your contacts manually.")
                } else {
                    //backup request
                    let contactString = targets.joinedWithComma()
                    let backupString = "Reported contacts: \(contactString)"
                    
                    let rawReport = RawReports()
                    let contactReport = ContactReport()
                    for target in targets {
                        contactReport.targets.append(target)
                    }
                    rawReport.contactReport = contactReport
                    
                    RealmHelper.logItem(data: backupString, rawReport: rawReport)
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    AlertHelperFunctions.presentAlert(title: "Success", message: "Reported \(targets.count) contacts.")
                }
            }
        } else {
            AlertHelperFunctions.presentAlert(title: "Error", message: "You must add at least one contact.")
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
        cell.textLabel?.text = (contact.firstName ?? "") + " " + (contact.lastName ?? "")
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
