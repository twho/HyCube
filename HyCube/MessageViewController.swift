//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import NMessenger
import AsyncDisplayKit
import PubNub

struct MyProfile {
    static let myId = "myId"
    static let myName = "myName"
    static let myEmail = "myEmail"
    static let myPic = "myPic"
    static let myFriendsName = "myFriendsName"
    static let myFriendsId = "myFriendsId"
}

class MessageViewController: UIViewController {
    @IBOutlet weak var btnStartChatting: BorderedButton!
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var btnStart: BorderedButton!
    
    var allUserIds: [String] = []
    var allUserNames: [String] = []
    var time: Float = 0.0
    var timer = Timer()
    
    let defaults = UserDefaults.standard
    let imgEnterClicked = (UIImage(named: "ic_enter")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgEnter = UIImage(named: "ic_enter")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnStartChatting.setImage(imgEnterClicked, for: .highlighted)
        btnStartChatting.setImage(imgEnter, for: .normal)
        loadAllUserImg()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnStartPressed(_ sender: BorderedButton) {
        let exampleViewController = MessengerViewController()
        navigationController?.pushViewController(exampleViewController, animated: true)
    }
    
    func setProgress() {
        let runtime = Float(allUserIds.count)
        progressBar.progress = (time / runtime)
        if time >= runtime {
            self.progressSpinner.isHidden = true
            self.progressBar.isHidden = true
            self.progressText.isHidden = true
            UIView.animate(withDuration: 1.5, animations: {
                self.btnStart.alpha = 1.0
            })
        }
    }
    
    func loadAllUserImg(){
        allUserIds = defaults.array(forKey: MyProfile.myFriendsId) as! [String]
        allUserNames = defaults.array(forKey: MyProfile.myFriendsName) as! [String]
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(LoginViewController.setProgress), userInfo: nil, repeats: true)
        var count = 0
        for userId in allUserIds {
            time += 1
            let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(userId)/picture?type=large")
            if let data = NSData(contentsOf: facebookProfileUrl!) {
                self.defaults.setValue(data as Data, forKey: allUserNames[count])
                self.defaults.synchronize()
            }
            count = count + 1
        }
    }
}
