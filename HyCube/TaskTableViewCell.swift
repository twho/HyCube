//
//  TaskTableViewCell.swift
//  HyCube
//
//  Created by Michael Ho on 12/5/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var ivAssign: UIImageView!
    @IBOutlet weak var tvTask: UILabel!
    @IBOutlet weak var tvFreq: UILabel!
    @IBOutlet weak var ivStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
