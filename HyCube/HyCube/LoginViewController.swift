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
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnSignUp: BorderedButton!
    
    let imgSignClicked = (UIImage(named: "ic_login")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgSign = (UIImage(named: "ic_login")?.maskWithColor(color: UIColor(red:0.29, green:0.53, blue:0.91, alpha:1.0))!)! as UIImage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSignUp.setImage(imgSignClicked, for: .highlighted)
        btnSignUp.setImage(imgSign, for: .normal)
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = btnFacebook.center
        view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
