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

        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    func getData() {
        SpinnerHelper.show()
        DataService.getUserStatus { (risk, error) in
            SpinnerHelper.hide()
            if error != nil {
                AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't fetch your status: " + error!.localizedDescription + " If this error persists please contact us and contact your school to manually report your contacts.")
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
