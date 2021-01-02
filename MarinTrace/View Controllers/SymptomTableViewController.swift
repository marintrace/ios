//
//  SymptomTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import SwaggerClient
import M13Checkbox

class SymptomTableViewController: UITableViewController {
    
    var symptoms = ["Fever or chills", "Cough", "Shortness of breath", "Difficulty breathing", "Fatigue", "Muscle or body aches", "Headache", "New loss of taste or smell", "Sore throat", "Congestion or runny nose", "Nausea or vomiting", "Diarrhea"]
    var screeners = ["I have been outside the state in the last 14 days", "I have been in contact with someone who has tested positive within the last 14 days"]
    var selections = [Bool]()
    var travel = false
    var proximity = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        //initialize selections array with all false
        selections = symptoms.map({_ in false})
    }
    
    func setupTableView() {
        //dissalow selection of cells
        tableView.allowsSelection = false
        
        //add header with description
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 110))
        let label = UITextView(frame: CGRect(x: 14, y: 0, width: self.view.frame.width-28, height: 100))
        //link text
        let descriptionText = NSMutableAttributedString(string:"Have you recently experienced any of these symptoms in the last 2-14 days? This list is from the Center For Disease Control's ", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .light)])
        let linkText = NSMutableAttributedString(string: "\"Symptoms of Coronavirus\"", attributes: [NSAttributedString.Key.link: URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/symptoms-testing/symptoms.html")!, .font:UIFont.systemFont(ofSize: 14, weight: .light)])
        let endText = NSMutableAttributedString(string:" webpage.", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .light)])
        descriptionText.append(linkText)
        descriptionText.append(endText)
        //set the link
        label.attributedText = descriptionText
        label.isUserInteractionEnabled = true
        label.isEditable = false
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = true
        label.sizeToFit()
        label.isScrollEnabled = false
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: label.frame.height + 10)
        headerView.addSubview(label)
        tableView.tableHeaderView = headerView
        
        //hide cells at bottom + separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        
        //setup dynamic height cells
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.setNeedsDisplay()
        tableView.reloadData()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        let checkedSymptoms = selections.reduce(0) { $0 + ($1 ? 1 : 0) }
        
        SpinnerHelper.show()
        //TODO add proximity + travel
        DataService.dailyReport(symptoms: checkedSymptoms, proximity: proximity, travel: travel) { (error) in
            SpinnerHelper.hide()
            if error != nil {
                AlertHelperFunctions.presentAlert(title: "Error", message: "Could't report symptoms: " +  error!.swaggerError + " If this error persists please contact us and please contact your school to report your symptoms manually.")
            } else {
                //regenerate notifications
                NotificationScheduler.scheduleNotifications()
                
                //backup
                let rawReport = RawReports()
                let dailyReport = DailyReport()
                dailyReport.numberOfSymptoms = checkedSymptoms
                dailyReport.proximity = self.proximity
                dailyReport.travel = self.travel
                rawReport.dailyReport = dailyReport
                RealmHelper.logItem(data: "Reported \(checkedSymptoms) symptoms, proximity: \(self.proximity ? "yes" : "no"), travel: \(self.travel ? "yes" : "no")", rawReport: rawReport)
                
                self.navigationController?.popViewController(animated: true)
                AlertHelperFunctions.presentAlert(title: "Success", message: "Daily questionnaire complete!")
            }
        }
    }
    
    @objc func screenerCheckboxChecked(_ sender: M13Checkbox) {
        let checked = (sender.checkState == .checked) ? true : false //convert enum to true/false
        if sender.tag == 0{
            travel = checked
        } else {
            proximity = checked
        }
    }
    
    @objc func symptomCheckboxChecked(_ sender: M13Checkbox) {
        let checked = (sender.checkState == .checked) ? true : false //convert enum to true/false
        selections[sender.tag] = checked
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return screeners.count
        } else {
            return symptoms.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SymptomTableViewCell
        
        if indexPath.section == 0 {
            cell.symptomLabel.text = screeners[indexPath.row]
            
            cell.checkbox.tag = indexPath.row
            cell.checkbox.addTarget(self, action: #selector(self.screenerCheckboxChecked(_:)), for: .valueChanged)
            
            //if its the first or last cell, round corners
            if indexPath.row == 0 {
                cell.backgroundRoundedView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            } else if indexPath.row == screeners.count - 1 {
                cell.backgroundRoundedView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
            }
        } else {
            cell.symptomLabel.text = symptoms[indexPath.row]
            
            //set tag of checkbox to index to see what checkbox they tapped
            cell.checkbox.tag = indexPath.row
            cell.checkbox.addTarget(self, action: #selector(self.symptomCheckboxChecked(_:)), for: .valueChanged)
            
            //if its the first or last cell, round corners
            if indexPath.row == 0 {
                cell.backgroundRoundedView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            } else if indexPath.row == symptoms.count - 1 {
                cell.backgroundRoundedView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
            }
        }

        return cell
    }

}
