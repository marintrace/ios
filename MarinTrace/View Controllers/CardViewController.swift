//
//  CardViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 9/25/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup labels
        nameLabel.text = User.fullName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        dateLabel.text = formatter.string(from: Date())

        tryCache()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    //for five min after submission, use cache in case there's a back log on backend
    func tryCache() {
        let cachedItems = RealmHelper.listItemsWithinFiveMinutes()
        let cachedWithDetail = cachedItems.filter({$0.rawReport?.dailyReport != nil || $0.rawReport?.testReport != nil}) //make sure it has rawReport data
        if cachedWithDetail.isEmpty { //no recent, fall back on DB
            getData()
            return
        }
        
        var description = ""
        var color = Colors.greenColor
        
        //get most recent daily report
        let daily = cachedWithDetail.first(where: {$0.rawReport!.dailyReport != nil})
        if let dailyDetail = daily?.rawReport?.dailyReport {
            let symptoms = dailyDetail.numberOfSymptoms
            description += "\(dailyDetail.numberOfSymptoms) Symptoms \n"
            
            if dailyDetail.travel {
                description += "Commercial Travel \n"
                color = Colors.yellowColor
            }
            if symptoms > 0 {
                color = Colors.redColor
            }
            if dailyDetail.proximity {
                description += "COVID Proximity \n"
                color = Colors.redColor
            }
        }
        
        //get most recent test result
        let test = cachedWithDetail.first(where: {$0.rawReport!.testReport != nil})
        if let testDetail = test?.rawReport?.testReport {
            if testDetail.type == "positive" {
                color = Colors.redColor
                description += "Positive Test"
            } else if testDetail.type == "negative" {
                color = Colors.greenColor
                description += "Negative Test"
            }
        }
        
        //update view
        descriptionLabel.text = description
        self.view.backgroundColor = color
    }
    
    func getData() {
        SpinnerHelper.show()
        DataService.getUserStatus { (risk, error) in
            SpinnerHelper.hide()
            if error != nil {
                AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't fetch your status: " + error!.swaggerError + " If this error persists please contact us and contact your school to manually report your contacts.")
            } else {
                //show description
                var str = ""
                for criterion in risk!.criteria! {
                    str += "\(criterion)\n"
                }
                self.descriptionLabel.text = str
                
                //show color
                switch risk?.color {
                case "danger":
                    self.view.backgroundColor = Colors.redColor
                case "yellow":
                    self.view.backgroundColor = Colors.yellowColor
                case "success":
                    self.view.backgroundColor = Colors.greenColor
                default:
                    self.view.backgroundColor = Colors.greyColor
                }
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
