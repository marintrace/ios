//
//  ReportHistoryTableViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 9/24/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import RealmSwift

class ReportHistoryTableViewController: UITableViewController {

    var items = [BackupEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup dynamic height cells
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension

        //get data
        items = RealmHelper.listItems()
        if items.isEmpty {
            self.dismiss(animated: true, completion: nil)
            AlertHelperFunctions.presentAlert(title: "Error", message: "Couldn't find any prior reports.")
        } else {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BackupTableViewCell
        
        let item = items[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M-d"
        let date = dateFormatter.string(from: item.date)

        cell.label!.text = "\(date): \(item.data)"
        cell.selectionStyle = .none

        return cell
    }

    @IBAction func exportTappped(_ sender: Any) {
        let alertController = UIAlertController(title: "Export Data:", message: "This data has your personal information and should only be shared with people you trust, for example your school if the system has an outage.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        let continueAction = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default) { [self]
            UIAlertAction in
            //create list w/ format "date/time: item"
            var str = ""
            for item in self.items {
                str.append("\(item.date): \(item.data)\n")
            }
            
            //present share controller
            let activityViewController = UIActivityViewController(activityItems: [str], applicationActivities: nil)
            alertController.dismiss(animated: true) {
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        alertController.addAction(okAction)
        alertController.addAction(continueAction)
        present(alertController, animated: true, completion: nil)
    }

}
