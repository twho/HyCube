//
//  PeopleViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/2/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var ivMyProfile: UIImageView!
    @IBOutlet weak var tvMyProfile: UILabel!
    
    let defaults = UserDefaults.standard
    
    struct myProfile {
        static let myId = "myId"
        static let myName = "myName"
        static let myEmail = "myEmail"
        static let myPic = "myPic"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tvMyProfile.text = defaults.string(forKey: myProfile.myName)
        self.ivMyProfile.image = UIImage(data: defaults.data(forKey: myProfile.myPic)! as Data)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
