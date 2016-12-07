//
//  SettingsViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/4/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit
import PubNub

class SensorViewController: UIViewController {

    
    @IBOutlet weak var sensorIcon: UIImageView!
    @IBOutlet weak var sensorName: UILabel!
    @IBOutlet weak var sensorImg: UIImageView!
    @IBOutlet weak var sensorCleanImg: CornerRadiusImageView!
    @IBOutlet weak var tvSensorStatus: UILabel!
    @IBOutlet weak var numberSensorStatus: UILabel!
    @IBOutlet weak var sensorIndicator: UILabel!
    @IBOutlet weak var sensorCleanIndicator: UILabel!
    @IBOutlet weak var sensorBar: UIProgressView!
    @IBOutlet weak var btnGetData: BorderedButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingIndicator2: UIActivityIndicatorView!
    var sensorImgList: [UIImage] = []
    var sensorNameList: [String] = ["Kitchen sensor", "Living Room sensor", "Bathroom sensor", "Sink sensor", "HyCube"]
    var sensorIndex: Int = 0
    
    var cleanPicChannelName: String = "HyCubeCleanPic"
    
    let imgSink: UIImage = UIImage(named: "ic_sink")!
    let imgImgSensor: UIImage = UIImage(named: "ic_cam")!
    let imgCube: UIImage = UIImage(named: "ic_cube")!
    let imgGetDataClicked = (UIImage(named: "ic_data")?.maskWithColor(color: UIColor.white)!)! as UIImage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingIndicator.isHidden = true
        self.sensorIndicator.isHidden = true
        self.btnGetData.setImage(imgGetDataClicked, for: .highlighted)
        sensorImgList = [imgImgSensor, imgImgSensor, imgImgSensor, imgSink, imgCube]
        sensorIcon.image = sensorImgList[sensorIndex]
        sensorName.text = sensorNameList[sensorIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnGetDataPressed(_ sender: BorderedButton) {
        getRegularPhoto()
        getCleanPhoto()
    }
    
    func getRegularPhoto(){
        self.loadingIndicator.isHidden = false
        let url_to_request = "http://140.118.7.117/hycube_ws/sensor_get_clean_pic.php"
        let url:NSURL = NSURL(string: url_to_request)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "sensor_name=regular_pic"
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
                        self.sensorImg.image = decodedimage
                        self.sensorIndicator.isHidden = false
                        self.loadingIndicator.isHidden = true
                    }
                }
            }
        }
        task.resume()
    }
    
    func getCleanPhoto(){
        self.loadingIndicator2.isHidden = false
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
                        self.sensorCleanImg.image = decodedimage
                        self.sensorCleanIndicator.isHidden = false
                        self.loadingIndicator2.isHidden = true
                    }
                }
            }
        }
        task.resume()
    }
    
    func fadeIn(imageView: UIImageView, withDuration duration: TimeInterval = 1.5) {
        imageView.alpha = 0.0
        UIView.animate(withDuration: duration, animations: {
            imageView.alpha = 1.0
        })
    }
}
