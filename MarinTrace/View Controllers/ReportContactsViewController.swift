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
    
    var contacts = [Contact]() //contacted people
    var contactOptions = [Contact]() //all contacts
    var suggestions = [Contact]() //suggestions for currently entered text
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setupTokenField()
        setupTableView()
    }
    
    func setupTokenField() {
        searchField.delegate = self
        searchField.dataSource = self
        searchField.placeholderText = "Search for a name"
        searchField.setColorScheme(Colors.colorFor(forSchool: User.school))
        searchField.toLabelText = ""
        searchField.delimiters = [","]
        searchField.becomeFirstResponder()
    }
    
    func setupTableView() {
        suggestionTableView.delegate = self
        suggestionTableView.dataSource = self
    }
    
    func getData() {
        self.showSpinner(onView: self.view)
        DataService.listUsers { (returnedContacts, error) in
            self.removeSpinner()
            if error != nil {
                AlertHelperFunctions.presentAlertOnVC(title: "Error", message: error!.localizedDescription, vc: self)
            } else {
                //filter for not this user
                self.contactOptions = returnedContacts!.filter({$0.email != DataService.getUserID()})
            }
        }
    }
    
    func getSuggestions(text: String) { //filter for user input, also make sure user not already selected
        suggestions = contactOptions.filter({$0.name.contains(text)})
        suggestions = suggestions.filter { (contact) -> Bool in
            return !contacts.contains(where: {$0.email  == contact.email})
        }
        suggestionTableView.reloadData()
    }
        
    //MARK: Search Field Code
    
    //when user types, filter suggestions
    func tokenField(_ tokenField: VENTokenField, didChangeText text: String?) {
        if let text = text {
            getSuggestions(text: text)
        }
    }
    
    //if user hits return, add top term as a token
    func tokenField(_ tokenField: VENTokenField, didEnterText text: String) {
        if !suggestions.isEmpty {
            let suggestion = suggestions[0]
            contacts.append(suggestion)
            searchField.reloadData()
            suggestions.removeAll(where: {$0.email == suggestion.email}) //remove selection from suggestions
            suggestionTableView.reloadData()
        }
    }
    
    func tokenField(_ tokenField: VENTokenField, didDeleteTokenAt index: UInt) {
        suggestions.append(contacts[Int(index)]) //re add to suggestions
        contacts.remove(at: Int(index))
        searchField.reloadData()
        suggestionTableView.reloadData()
    }
    
    func numberOfTokens(in tokenField: VENTokenField) -> UInt {
        return UInt(contacts.count)
    }
    
    func tokenField(_ tokenField: VENTokenField, titleForTokenAt index: UInt) -> String {
        return contacts[Int(index)].name
    }
    
    //MARK: Table View Code
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = suggestionTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row].name
        return cell
    }
    
    //if user selects row, add person as token
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        contacts.append(suggestion)
        searchField.reloadData()
        suggestions.removeAll(where: {$0.email == suggestion.email})  //remove selection from suggestions
        suggestionTableView.reloadData()
    }
        
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ContactedCohortsViewController {
            destination.contacts = contacts //send selected names to summary screen
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
