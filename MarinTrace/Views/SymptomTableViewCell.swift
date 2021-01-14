//
//  SymptomTableViewCell.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import UIKit
import M13Checkbox

class SymptomTableViewCell: UITableViewCell {

    @IBOutlet weak var symptomLabel: UILabel!
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var backgroundRoundedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //setup checkbox
        checkbox.stateChangeAnimation = .bounce(.fill)
        checkbox.tintColor = Colors.colorFor(forSchool: User.school)
        
    }
    
    override func prepareForReuse() {
        self.setNeedsDisplay()
        self.layoutIfNeeded()
    }
    
    /*override func layoutSubviews() {
        super.layoutSubviews()
        
        let oldFrame = self.backgroundRoundedView.frame
        self.backgroundRoundedView.frame = CGRect(origin: oldFrame.origin, size: CGSize(width: oldFrame.size.width, height: self.symptomLabel.frame.height + 22))
        
        self.backgroundRoundedView.setNeedsDisplay()
        self.backgroundRoundedView.setNeedsUpdateConstraints()
        self.layoutIfNeeded()
    }*/

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
