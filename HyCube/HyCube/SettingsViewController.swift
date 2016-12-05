//
//  SetttingsViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/5/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    var sensorList: [String] = ["Kitchen sensor", "Living Room sensor", "Bathroom sensor", "Sink sensor", "HyCube"]
    var sensorImgList: [UIImage] = []
    var sensorStatusList: [String] = ["Status: clean", "Status: clean", "Status: clean", "Status: clean", "Status: connected"]
    //0=sensor, 1=device(cube)
    var sensorTypeList: [Int] = [0, 0, 0, 0, 1]
    
    let imgSink: UIImage = UIImage(named: "ic_sink")!
    let imgImgSensor: UIImage = UIImage(named: "ic_cam")!
    let imgCube: UIImage = UIImage(named: "ic_cube")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        sensorImgList = [imgImgSensor, imgImgSensor, imgImgSensor, imgSink, imgCube]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")! as! SettingsTableViewCell
        cell.tvSensor.text = sensorList[indexPath.row]
        cell.ivSensor.image = sensorImgList[indexPath.row]
        cell.tvStatus.text = sensorStatusList[indexPath.row]
        return cell
    }
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}
