//
//  BorderedButton.swift
//  CARt
//
//  Created by Michael Ho on 10/16/16.
//  Copyright © 2016 cartrides.org. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1.0
        layer.borderColor = tintColor.cgColor
        layer.cornerRadius = 15.0
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setBackgroundImage(UIImage(color: UIColor.white), for: .normal)
        setBackgroundImage(UIImage(color: tintColor), for: .highlighted)
        setTitleColor(tintColor, for: .normal)
        setTitleColor(UIColor.white, for: .highlighted)
    }
}
