//
//  ContactedCohortsViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit

class ContactedCohortsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cohortTableView: UITableView!
    
    var contacts = [Contact]() //a list of the people they've contacted
    var cohorts = [String]() //a list of the unique cohorts they've contacted
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup table view
        cohortTableView.dataSource = self
        cohortTableView.delegate = self
        
        processData()
        
    }
    
    func processData() {
        //get list of cohort names and remove duplicates
        let cohortNames: [String] = contacts.map({$0.cohort})
        cohorts = cohortNames.uniques
        cohortTableView.reloadData()
    }
    
    @IBAction func reportContacts(_ sender: Any) {
  
        let dispatch = DispatchGroup() //dispatch group to track completion of all posts
        var error: Error? //if there's an error track it
        
        //report each contact
        for contact in contacts {
            dispatch.enter()
            DataService.reportInteraction(personBID: contact.id) { (requestError) in
                if requestError != nil {
                    error = requestError as! Error
                }
                dispatch.leave()
            }
        }
        
        //wait for all posts to finish
        dispatch.notify(queue: .main) {
            if error != nil { //if an error showed up, report it
                AlertHelperFunctions.presentAlertOnVC(title: "Error", message: error!.localizedDescription, vc: self)
            } else { //else go back
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    //MARK: Table View Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cohorts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cohortTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cohorts[indexPath.row]
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
