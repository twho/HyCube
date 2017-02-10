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
    @IBOutlet weak var tvChatInstr: UILabel!
    @IBOutlet weak var btnChat: BorderedButton!
    @IBOutlet weak var btnSendReminders: BorderedButton!
    
    let defaults = UserDefaults.standard
    
    let imgChatClicked = (UIImage(named: "ic_chat")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgRemindersClicked = (UIImage(named: "ic_reminder")?.maskWithColor(color: UIColor.white)!)! as UIImage
    
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
        btnChat.setImage(imgChatClicked, for: .highlighted)
        btnSendReminders.setImage(imgRemindersClicked, for: .highlighted)
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self, action:#selector(iv1Tapped))
        ivUser1.addGestureRecognizer(tapGestureRecognizer1)
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(iv2Tapped))
        ivUser2.addGestureRecognizer(tapGestureRecognizer2)
        let tapGestureRecognizer3 = UITapGestureRecognizer(target:self, action:#selector(iv3Tapped))
        ivUser3.addGestureRecognizer(tapGestureRecognizer3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func iv1Tapped(){
        setButton(index: 0)
    }
    
    func iv2Tapped(){
        setButton(index: 1)
    }
    
    func iv3Tapped(){
        setButton(index: 2)
    }
    
    func setButton(index: Int) {
        tvChatInstr.isHidden = true
        switch index {
        case 0:
            btnChat.setTitle("Chat with \(tvUser1.text!)", for: .normal)
            break
        case 1:
            btnChat.setTitle("Chat with \(tvUser2.text!)", for: .normal)
            break
        case 2:
            btnChat.setTitle("Chat with \(tvUser3.text!)", for: .normal)
            break
        default:
            break
        }
        btnChat.titleLabel!.adjustsFontSizeToFitWidth = true
        fadeIn(btnView: btnChat)
        fadeIn(btnView: btnSendReminders)
    }
    
    func fadeIn(btnView: BorderedButton, withDuration duration: TimeInterval = 1.5) {
        btnView.alpha = 0.0
        UIView.animate(withDuration: duration, animations: {
            btnView.alpha = 1.0
        })
    }
    
    func loadAllUserImg(){
        allUserIds = defaults.array(forKey: MyProfile.myFriendsId) as! [String]
        allUserNames = defaults.array(forKey: MyProfile.myFriendsName) as! [String]
        var imgCount = 0
        var count = 0
        for userId in allUserIds {
            let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")
            if(userId != defaults.string(forKey: MyProfile.myId) && count < 4){
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
