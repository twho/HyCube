//
//  ResetSensorViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/7/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit
import PubNub

class ResetSensorViewController: UIViewController, PNObjectEventListener {
    
    var mainChannelName: String = "HyCubeTakeNewPhoto"
    
    @IBOutlet weak var ivPicture: CornerRadiusImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnSetPic: UIButton!
    @IBOutlet weak var tvInstruction1: UILabel!
    @IBOutlet weak var tvInstruction2: UILabel!
    @IBOutlet weak var tvWaiting: UILabel!
    @IBOutlet weak var btnTakePic: BorderedButton!
    var blinking = false
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let imgTakeClicked = (UIImage(named: "ic_camera")?.maskWithColor(color: UIColor.white)!)! as UIImage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnTakePic.setImage(imgTakeClicked, for: .highlighted)
        appDelegate.client.addListener(self)
        appDelegate.client.subscribeToChannels([mainChannelName], withPresence: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("\(message.data.message!) at \(message.data.channel)")
        if(mainChannelName == "\(message.data.channel)" && "Uploadedclean_pic" == "\(message.data.message!)"){
            self.tvWaiting.isHidden = true
            getPhoto()
        }
    }

    
    @IBAction func btnTakePicPressed(_ sender: BorderedButton) {
        self.tvWaiting.isHidden = false
        takePhoto()
    }
    
    func takePhoto(){
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
    
    func getPhoto(){
        self.loadingIndicator.isHidden = false
        let url_to_request = "http://140.118.7.117/hycube_ws/sensor_get_clean_pic.php"
        let url:NSURL = NSURL(string: url_to_request)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "sensor_name=clean_pic"
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
                    DispatchQueue.main.async() { () -> Void in
                        self.ivPicture.image = decodedimage
                        self.tvInstruction1.isHidden = false
                        self.tvInstruction2.isHidden = false
                        self.btnSetPic.isHidden = false
                        self.loadingIndicator.isHidden = true
                    }
                }
            }
        }
        task.resume()
    }
}
