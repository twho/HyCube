//
//  DeviceViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/7/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController {
    
    @IBOutlet weak var btnStandard: BorderedButton!
    @IBOutlet weak var btnParty: BorderedButton!
    @IBOutlet weak var btnRainbow: BorderedButton!
    @IBOutlet weak var tvMode: UILabel!
    
    let imgStandardOn = (UIImage(named: "ic_display")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgPartyOn = (UIImage(named: "ic_party")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgRainbowOn = (UIImage(named: "ic_rainbow")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvMode.text = "Mode: Standard"
        btnStandard.setImage(imgStandardOn, for: .highlighted)
        btnParty.setImage(imgPartyOn, for: .highlighted)
        btnRainbow.setImage(imgRainbowOn, for: .highlighted)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnStandardPressed(_ sender: BorderedButton) {
        self.tvMode.text = "Mode: Standard"
        changeMode(mode: "yellow")
    }
    
    @IBAction func btnPartyPressed(_ sender: BorderedButton) {
        self.tvMode.text = "Mode: Party"
        changeMode(mode: "party")
    }
    
    @IBAction func btnRainbowPressed(_ sender: BorderedButton) {
        self.tvMode.text = "Mode: Rainbow"
        changeMode(mode: "rainbow")
    }
    
    func changeMode(mode: String){
        let url_to_request = "http://linino.local/mailbox/\(mode)"
        let url:NSURL = NSURL(string: url_to_request)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = ""
        request.httpBody = paramString.data(using: String.Encoding.utf8
        )
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString!)
        }
        task.resume()
    }
}
