//
//  SymptomTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit

class SymptomTableViewController: UITableViewController {
    
    var symptoms = ["Fever or chills", "Cough", "Shortness of breath", "Difficulty breathing", "Fatigue", "Muscle or body aches", "Headache", "New loss of taste or smell", "Sore throat", "Congestion or runny nose", "Nausea or vomiting", "Diarrhea"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        
        //dissalow selection of cells
        tableView.allowsSelection = false
        
        //add header with description
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        let label = UILabel(frame: CGRect(x: 14, y: 0, width: self.view.frame.width-28, height: 40))
        label.text = "Have you recently experienced any of these symptoms in the last 2-14 days?"
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        headerView.addSubview(label)
        tableView.tableHeaderView = headerView
        
        //hide cells at bottom + separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        
    }

    @IBAction func donePressed(_ sender: Any) {
        
        //get checked symptoms by looking at table view rows and seeing which are checked
        var checkedSymptoms = [String]()
        for symptomIndex in 0..<symptoms.count {
            let cell = tableView.cellForRow(at: IndexPath(row: symptomIndex, section: 0)) as! SymptomTableViewCell
            if cell.checkbox.checkState == .checked {
                checkedSymptoms.append(symptoms[symptomIndex])
            }
        }
        
        //report if there are 2+ symptoms
        if checkedSymptoms.count > 1 {
            self.showSpinner(onView: self.view)
            DataService.notifyRisk(criteria: checkedSymptoms) { (error) in
                self.removeSpinner()
                if error != nil {
                    AlertHelperFunctions.presentAlertOnVC(title: "Error", message: error!.localizedDescription, vc: self)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SymptomTableViewCell
        
        cell.symptomLabel.text = symptoms[indexPath.row]
        
        //if its the first or last cell, round corners
        if indexPath.row == 0 {
            cell.backgroundRoundedView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        } else if indexPath.row == symptoms.count - 1 {
            cell.backgroundRoundedView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        }

        return cell
    }

}
