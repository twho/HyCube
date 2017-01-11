//
//  SettingsTableViewCell.swift
//  HyCube
//
//  Created by Michael Ho on 12/5/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivSensor: UIImageView!
    @IBOutlet weak var tvSensor: UILabel!
    @IBOutlet weak var tvStatus: UILabel!
    @IBOutlet weak var ivConnect: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
