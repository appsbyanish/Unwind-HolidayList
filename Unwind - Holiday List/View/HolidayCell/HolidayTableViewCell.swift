//
//  HolidayTableViewCell.swift
//  Unwind - Holiday List
//
//  Created by Anishgopal Venugopal on 04/11/18.
//  Copyright © 2018 Anishgopal Venugopal. All rights reserved.
//

import UIKit
import SwipeCellKit

class HolidayTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var holidayDate: UILabel!
    @IBOutlet weak var holidayName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
