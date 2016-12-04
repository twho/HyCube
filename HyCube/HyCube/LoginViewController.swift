//
//  LoginViewController.swift
//  HyCube
//
//  Created by Michael Ho on 11/30/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit
import PubNub
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController, PNObjectEventListener {

    @IBOutlet weak var edEmail: UITextField!
    @IBOutlet weak var edPassword: UITextField!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnSignUp: BorderedButton!
    @IBOutlet weak var progressSpinner: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var ivProfileImg: UIImageView!
    @IBOutlet weak var tvProfile: UILabel!
    
    let imgSignClicked = (UIImage(named: "ic_login")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgSign = (UIImage(named: "ic_login")?.maskWithColor(color: UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0))!)! as UIImage
    let defaults = UserDefaults.standard
    let myLoginButton = UIButton(type: .custom)
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let serialQueue: DispatchQueue = DispatchQueue(label: "pageHistoryQueue", attributes: [])
    
    var userDataChannelName: String = "HyCubeUser3"
    var allUserIds: [String] = []
    var allUserNames: [String] = []
    var time: Float = 0.0
    var timer = Timer()
    var start: Bool = true
    
    struct MyProfile {
        static let myId = "myId"
        static let myName = "myName"
        static let myEmail = "myEmail"
        static let myPic = "myPic"
        static let myFriendsName = "myFriendsName"
        static let myFriendsId = "myFriendsId"
    }
    
    struct HyCubeUserKeys {
        static let userId = "userId"
        static let userName = "userName"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.client.addListener(self)
        appDelegate.client.subscribeToChannels([userDataChannelName], withPresence: false)
        btnSignUp.setImage(imgSignClicked, for: .highlighted)
        btnSignUp.setImage(imgSign, for: .normal)
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email])
        loginButton.center = btnFacebook.center
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getMyFacebookProfilePic()
        if start {
            serialQueue.async { [unowned self] () -> Void in
                self.loadAllUsers()
            }
        } else {
            start = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getMyFacebookProfilePic(){
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me")) { httpResponse, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
                self.defaults.setValue("\(response.dictionaryValue?["id"] as! String)", forKey: MyProfile.myId)
                self.defaults.setValue("\(response.dictionaryValue?["name"] as! String)", forKey: MyProfile.myName)
                self.defaults.synchronize()
                self.edEmail.isHidden = true
                self.edPassword.isHidden = true
                self.progressSpinner.isHidden = false
                self.progressBar.isHidden = false
                self.tvProfile.isHidden = false
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(LoginViewController.setProgress), userInfo: nil, repeats: true)
                if(!self.allUserIds.contains(self.defaults.string(forKey: MyProfile.myId)!)){
                    let message : [String : AnyObject] = [HyCubeUserKeys.userId : self.defaults.string(forKey: MyProfile.myId)! as AnyObject, HyCubeUserKeys.userName : self.defaults.string(forKey: MyProfile.myName)! as AnyObject]
                    self.appDelegate.client.publish(message, toChannel: self.userDataChannelName, withCompletion: nil)
                }
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    func setProgress() {
        time += 0.1
        progressBar.progress = (time / 5)
        if time >= 5 {
            self.progressSpinner.isHidden = true
            self.progressBar.isHidden = true
            loadProfileImg()
            self.btnSignUp.setTitle("Continue", for: .normal)
            self.btnSignUp.setTitle("Continue", for: .highlighted)
        }
    }
    
    func loadProfileImg(){
        let imgId = NSString(string: defaults.string(forKey: MyProfile.myId)!)
        let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(imgId)/picture?type=large")
        if let data = NSData(contentsOf: facebookProfileUrl!) {
            self.ivProfileImg.image = UIImage(data: data as Data)
            self.defaults.setValue(data as Data, forKey: MyProfile.myPic)
            self.defaults.synchronize()
            UIView.animate(withDuration: 2.0, animations: {
                self.ivProfileImg.alpha = 1.0
            })
            self.tvProfile.text = defaults.string(forKey: MyProfile.myName)
        }
    }
    
    func loadAllUsers() {
        
        var shouldStop: Bool = false
        var isPaging: Bool = false
        var startTimeToken: NSNumber = 0
        let itemLimit: Int = 20
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        
        self.appDelegate.client.historyForChannel(userDataChannelName, start: nil, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
            for message in (result?.data.messages)! {
                if let resultMessage = (message as! [String:AnyObject])["message"] {
                    self.addUserToArray(messageData: resultMessage as! [String : AnyObject])
                }
            }
            
            if let endTime = result?.data.end {
                startTimeToken = endTime
            }
            
            if result?.data.messages.count == itemLimit {
                isPaging = true
            }
            semaphore.signal()
        })
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        
        while isPaging && !shouldStop {
            self.appDelegate.client.historyForChannel(userDataChannelName, start: startTimeToken, end: nil, limit: 100, reverse: true, includeTimeToken: true, withCompletion: { (result, status) in
                for message in (result?.data.messages)! {
                    if let resultMessage = (message as! [String:AnyObject])["message"] {
                        self.addUserToArray(messageData: resultMessage as! [String : AnyObject])
                    }
                }
                
                if let endTime = result?.data.end {
                    startTimeToken = endTime
                }
                
                if (result?.data.messages.count)! < itemLimit {
                    shouldStop = true
                }
                semaphore.signal()
            })
            
            semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        self.defaults.setValue(self.allUserIds, forKey: MyProfile.myFriendsId)
        self.defaults.setValue(self.allUserNames, forKey: MyProfile.myFriendsName)
        self.defaults.synchronize()
    }
    
    func addUserToArray(messageData: [String:AnyObject]){
        if(!self.allUserIds.contains(messageData["\(HyCubeUserKeys.userId)"] as! String)){
            self.allUserIds.append(messageData["\(HyCubeUserKeys.userId)"] as! String)
            self.allUserNames.append(messageData["\(HyCubeUserKeys.userName)"] as! String)
        }
    }
}
