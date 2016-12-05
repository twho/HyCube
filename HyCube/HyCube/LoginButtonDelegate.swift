//
//  File.swift
//  HyCube
//
//  Created by Michael Ho on 12/2/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import Foundation
import FacebookLogin
import FacebookCore

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        getMyFacebookProfilePic()
        print("Did complete login via LoginButton with result \(result)")
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Did logout via LoginButton")
    }
}
