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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup labels
        nameLabel.text = User.fullName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        dateLabel.text = formatter.string(from: Date())

        //check if there are any symptom reports from today
        let reports = RealmHelper.listItems().filter({Calendar.current.isDateInToday($0.date)}) //get reports from today
        if let symptomReport = reports.first(where: {$0.data.contains("symptoms")}) { //fetch most recent symptom report
            if symptomReport.data.contains("0") { //extract number of symptoms
                self.view.backgroundColor = Colors.greenColor
            } else {
                self.view.backgroundColor = Colors.redColor
            }
        } else {
            self.view.backgroundColor = Colors.redColor
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .systemBlue
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
