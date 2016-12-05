//
//  SettingsViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/4/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit
import PubNub

class SensorViewController: UIViewController, PNObjectEventListener {

    @IBOutlet weak var sensorImg: UIImageView!
    
    var cleanPicChannelName: String = "HyCubeCleanPic"
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.client.addListener(self)
        appDelegate.client.subscribeToChannels([cleanPicChannelName], withPresence: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSensePressed(_ sender: BorderedButton) {
        takeCleanPhoto()
    }
    
    @IBAction func btnSeePressed(_ sender: BorderedButton) {
        getCleanPhoto()
    }
    
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        if(cleanPicChannelName == "\(message.data.channel)"){
            getCleanPhoto()
        } else {
        }
    }
    
    func takeCleanPhoto(){
        let url_to_request = "http://192.168.2.2/mailbox/takePic"
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
    
    func getCleanPhoto(){
        let url_to_request = "http://140.118.7.117/hycube_ws/sensor_get_clean_pic.php"
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
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
            if("" != dataString && dataString.characters.count >= 10){
                if(dataString.contains("ImgSuccess")){
                    let imgString = dataString.components(separatedBy: "ImgSuccess")[1]
                    let dataDecoded: NSData = NSData(base64Encoded: imgString, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                    self.sensorImg.image = decodedimage
                }
            }
        }
        
        task.resume()
    }
}
