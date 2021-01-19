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
    @IBOutlet weak var permittedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup labels
        nameLabel.text = User.fullName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE\nM/d/yy"
        dateLabel.text = formatter.string(from: Date())

        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    //for five min after submission, use cache in case there's a back log on backend
    func tryCache() {
        DataService.logMessage(message: "trying cache for card")
        
        let cachedItems = RealmHelper.listItemsWithinFiveMinutes()
        let cachedWithDetail = cachedItems.filter({$0.rawReport?.dailyReport != nil || $0.rawReport?.testReport != nil}) //make sure it has rawReport data
        if cachedWithDetail.isEmpty { //no recent, show no report
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
                color = Colors.redColor
            }
            if symptoms > 1 {
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
        if color != Colors.greenColor {
            permittedLabel.text = "❌ Not permitted to enter campus"
        } else {
            permittedLabel.text = "✅ Permitted to enter campus"
        }
    }
    
    func getData() {
        SpinnerHelper.show()
        DataService.logMessage(message: "getting status")
        DataService.getUserStatus { (status, error) in
            SpinnerHelper.hide()
            if error != nil {
                AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't fetch your status: " + error!.swaggerError + " If this error persists please contact us and contact your school.")
            } else {
                guard let userStatus = status else {
                    self.tryCache() //no status, try cache
                    return
                }
                
                if userStatus.entry {
                    self.permittedLabel.text = "✅ Permitted to enter campus"
                } else {
                    self.permittedLabel.text = "❌ Not permitted to enter campus"
                }
                
                //show either location or other criteria
                if userStatus.reason == .location {
                    self.descriptionLabel.text = "You are currently \(userStatus.location?.location?.rawValue ?? "[LOCATION UNKNOWN]")"
                    
                    //show color
                    switch userStatus.location?.color {
                    case .danger:
                        self.view.backgroundColor = Colors.redColor
                    case .yellow:
                        self.view.backgroundColor = Colors.yellowColor
                    case .success:
                        self.view.backgroundColor = Colors.greenColor
                    default:
                        self.view.backgroundColor = Colors.greyColor
                    }
                } else {
                    if let health = userStatus.health {
                        var str = ""
                        for criterion in health.criteria ?? [] {
                            str += "\(criterion)\n"
                        }
                        self.descriptionLabel.text = str
                        
                        //show color - should ideally use a function bc DRY, but the enum isn't a shared type between health.color and location.color
                        switch health.color {
                        case .danger:
                            self.view.backgroundColor = Colors.redColor
                        case .yellow:
                            self.view.backgroundColor = Colors.yellowColor
                        case .success:
                            self.view.backgroundColor = Colors.greenColor
                        default:
                            self.view.backgroundColor = Colors.greyColor
                        }
                    }
                }
                
                //if no report (marked in criteria) and no location set, then try cache (server might be held up processing a report)
                if self.descriptionLabel.text!.contains("No Report") && userStatus.location?.location == .campus {
                    self.tryCache()
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
