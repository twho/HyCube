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
    @IBOutlet weak var ivUser1: UIImageView!
    @IBOutlet weak var ivUser2: UIImageView!
    @IBOutlet weak var ivUser3: UIImageView!
    @IBOutlet weak var tvUser1: UILabel!
    @IBOutlet weak var tvUser2: UILabel!
    @IBOutlet weak var tvUser3: UILabel!
    
    let defaults = UserDefaults.standard
    
    var userIvs: [UIImageView] = []
    var userTvs: [UILabel] = []
    var allUserNames: [String] = []
    var allUserIds: [String] = []
    
    struct HyCubeUsers {
        var userId: String
        var userName: String
    }
    
    struct MyProfile {
        static let myId = "myId"
        static let myName = "myName"
        static let myEmail = "myEmail"
        static let myPic = "myPic"
        static let myFriendsName = "myFriendsName"
        static let myFriendsId = "myFriendsId"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tvMyProfile.text = defaults.string(forKey: MyProfile.myName)
        self.ivMyProfile.image = UIImage(data: defaults.data(forKey: MyProfile.myPic)! as Data)
        self.userIvs = [ivUser1, ivUser2, ivUser3]
        self.userTvs = [tvUser1, tvUser2, tvUser3]
        self.loadAllUserImg()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAllUserImg(){
        allUserIds = defaults.array(forKey: MyProfile.myFriendsId) as! [String]
        allUserNames = defaults.array(forKey: MyProfile.myFriendsName) as! [String]
        var imgCount = 0
        var count = 0
        for userId in allUserIds {
            let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")
            if(userId != defaults.string(forKey: MyProfile.myId) && count < 3){
                print("\(count)")
                if let data = NSData(contentsOf: facebookProfileUrl!) {
                    self.userIvs[imgCount].image = UIImage(data: data as Data)
                    self.userTvs[imgCount].text = allUserNames[count]
                    UIView.animate(withDuration: 2.0, animations: {
                        self.userTvs[imgCount].alpha = 1.0
                        self.userIvs[imgCount].alpha = 1.0
                    })
                }
                imgCount = imgCount + 1
            }
            count = count + 1
        }
    }
}
