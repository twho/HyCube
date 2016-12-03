//
//  LoginViewController.swift
//  HyCube
//
//  Created by Michael Ho on 11/30/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController {

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
    
    var time: Float = 0.0
    var timer = Timer()
    
    struct myProfile {
        static let myId = "myId"
        static let myName = "myName"
        static let myEmail = "myEmail"
        static let myPic = "myPic"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSignUp.setImage(imgSignClicked, for: .highlighted)
        btnSignUp.setImage(imgSign, for: .normal)
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email])
        loginButton.center = btnFacebook.center
        loginButton.delegate = self
        view.addSubview(loginButton)
        getMyFacebookProfilePic()
        self.hideKeyboardWhenTappedAround()
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
                self.defaults.setValue("\(response.dictionaryValue?["id"] as! String)", forKey: myProfile.myId)
                self.defaults.setValue("\(response.dictionaryValue?["name"] as! String)", forKey: myProfile.myName)
                self.defaults.synchronize()
                self.edEmail.isHidden = true
                self.edPassword.isHidden = true
                self.progressSpinner.isHidden = false
                self.progressBar.isHidden = false
                self.tvProfile.isHidden = false
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(LoginViewController.setProgress), userInfo: nil, repeats: true)
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
    }
    
    func setProgress() {
        time += 0.1
        progressBar.progress = (time / 2)
        if time >= 2 {
            self.progressSpinner.isHidden = true
            self.progressBar.isHidden = true
            loadProfileImg()
            self.btnSignUp.setTitle("Continue", for: .normal)
            self.btnSignUp.setTitle("Continue", for: .highlighted)
        }
    }
    
    func loadProfileImg(){
        let imgId = NSString(string: defaults.string(forKey: myProfile.myId)!)
        let facebookProfileUrl = URL(string: "http://graph.facebook.com/\(imgId)/picture?type=large")
        if let data = NSData(contentsOf: facebookProfileUrl!) {
            self.ivProfileImg.image = UIImage(data: data as Data)
            self.defaults.setValue(data as Data, forKey: myProfile.myPic)
            self.defaults.synchronize()
            UIView.animate(withDuration: 2.0, animations: {
                self.ivProfileImg.alpha = 1.0
            })
            self.tvProfile.text = defaults.string(forKey: myProfile.myName)
        }
    }
}
