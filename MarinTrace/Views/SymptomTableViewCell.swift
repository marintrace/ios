//
//  SymptomTableViewCell.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit

class SymptomTableViewCell: UITableViewCell {

    @IBOutlet weak var symptomLabel: UILabel!
    @IBOutlet weak var checkbox: CircularCheckbox!
    @IBOutlet weak var backgroundRoundedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //self.backgroundColor = .white
        //self.preservesSuperviewLayoutMargins = false
        //self.layoutMargins = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
