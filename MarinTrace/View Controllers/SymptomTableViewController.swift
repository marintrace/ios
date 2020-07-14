//
//  SymptomTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import SwaggerClient

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
        
        var feverChills = false
        var cough = false
        var shortnessBreath = false
        var difficultyBreathing = false
        var fatigue = false
        var muscleBodyAches = false
        var headache = false
        var lossTasteSmell = false
        var soreThroat = false
        var congestionRunnyNose = false
        var nauseaVomiting = false
        var diarrhea = false
        
        for symptomIndex in 0..<symptoms.count {
            let cell = tableView.cellForRow(at: IndexPath(row: symptomIndex, section: 0)) as! SymptomTableViewCell
            if cell.checkbox.checkState == .checked {
                switch symptomIndex {
                case 0: feverChills = true
                case 1: cough = true
                case 2: shortnessBreath = true
                case 3: difficultyBreathing = true
                case 4: fatigue = true
                case 5: muscleBodyAches = true
                case 6: headache = true
                case 7: lossTasteSmell = true
                case 8: soreThroat = true
                case 9: congestionRunnyNose = true
                case 10: nauseaVomiting = true
                case 11: diarrhea = true
                default:
                    break
                }
            }
        }
        
        self.showSpinner(onView: self.view)
        DataService.reportSymptoms(symptoms: SwaggerClient.SymptomReport(feverChills: feverChills, cough: cough, shortnessBreath: shortnessBreath, difficultyBreathing: difficultyBreathing, fatigue: fatigue, muscleBodyAches: muscleBodyAches, headache: headache, lossTasteSmell: lossTasteSmell, soreThroat: soreThroat, congestionRunnyNose: congestionRunnyNose, nauseaVomiting: nauseaVomiting, diarrhea: diarrhea)) { (error) in
            self.removeSpinner()
            if error != nil {
                AlertHelperFunctions.presentAlertOnVC(title: "Error", message: error!.localizedDescription, vc: self)
            } else {
                //regenerate notifications
                NotificationScheduler.scheduleNotifications()
                
                self.navigationController?.popViewController(animated: true)
            }
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
