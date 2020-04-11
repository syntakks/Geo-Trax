//
//  TripCell.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/7/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import UIKit

class TripCell: UITableViewCell {
    static let reuseIdentifier = "TripCell"
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
