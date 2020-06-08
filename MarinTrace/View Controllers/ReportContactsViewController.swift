//
//  ReportContactsViewController.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import VENTokenField

class ReportContactsViewController: UIViewController, VENTokenFieldDelegate, VENTokenFieldDataSource, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchField: VENTokenField!
    @IBOutlet weak var suggestionTableView: UITableView!
    
    var names = [String]()
    var suggestionOptions = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"] //all possible suggestions
    var suggestions = [String]() //suggestions for currently entered text
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup token field
        searchField.delegate = self
        searchField.dataSource = self
        searchField.placeholderText = "Search for a name"
        searchField.setColorScheme(Colors.SchoolColors.MA)
        searchField.toLabelText = ""
        searchField.delimiters = [","]
        searchField.becomeFirstResponder()
        
        //Setup table view
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
        
    }
    
    func getSuggestions(text: String) {
        suggestions = suggestionOptions.filter({$0.contains(text) && !names.contains(text)})
        suggestionTableView.reloadData()
    }
        
    //MARK: SearchField Code
    
    //when user types, filter suggestions for input, also make sure user not already selected
    func tokenField(_ tokenField: VENTokenField, didChangeText text: String?) {
        if let text = text {
            getSuggestions(text: text)
        }
    }
    
    //if user hits return, add top term as a token
    func tokenField(_ tokenField: VENTokenField, didEnterText text: String) {
        if !suggestions.isEmpty {
            let suggestion = suggestions[0]
            names.append(suggestion)
            searchField.reloadData()
            suggestions.removeAll(where: {$0 == suggestion}) //remove selection from suggestions
            suggestionTableView.reloadData()
        }
    }
    
    func tokenField(_ tokenField: VENTokenField, didDeleteTokenAt index: UInt) {
        names.remove(at: Int(index))
        searchField.reloadData()
        suggestionTableView.reloadData()
    }
    
    func numberOfTokens(in tokenField: VENTokenField) -> UInt {
        return UInt(names.count)
    }
    
    func tokenField(_ tokenField: VENTokenField, titleForTokenAt index: UInt) -> String {
        return names[Int(index)]
    }
    
    //MARK: Table View Code
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = suggestionTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }
    
    //if user selects row, add person as token
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        names.append(suggestion)
        searchField.reloadData()
        suggestions.removeAll(where: {$0 == suggestion}) //remove selection from suggestions
        suggestionTableView.reloadData()
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
