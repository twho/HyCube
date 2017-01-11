//
//  SetttingsViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/5/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit

struct Sensor {
    var sensorName: String
    var sensorImg: UIImage
    var sensorConnect: UIImage
    var sensorStatus: String
    var sensorType: Int
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
    var sensorList: [Sensor] = []
    var sensorNameList: [String] = ["Kitchen sensor", "Living Room sensor", "Bathroom sensor", "Sink sensor", "HyCube"]
    var sensorImgList: [UIImage] = []
    var sensorConnectList: [UIImage] = []
    var sensorStatusList: [String] = ["Status: clean", "Status: clean", "Status: clean", "Status: clean", "Status: connected"]
    //0=sensor, 1=device(cube)
    var sensorTypeList: [Int] = [0, 0, 0, 0, 1]
    
    let imgSink: UIImage = UIImage(named: "ic_sink")!
    let imgImgSensor: UIImage = UIImage(named: "ic_cam")!
    let imgCube: UIImage = UIImage(named: "ic_cube")!
    let imgGoodConnect: UIImage = UIImage(named: "ic_goodconnect")!
    let imgMedConnect: UIImage = UIImage(named: "ic_medconnect")!
    let imgPoorConnect: UIImage = UIImage(named: "ic_poorconnect")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        sensorImgList = [imgImgSensor, imgImgSensor, imgImgSensor, imgSink, imgCube]
        sensorConnectList = [imgGoodConnect, imgPoorConnect, imgPoorConnect, imgPoorConnect, imgGoodConnect]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    @IBAction func backFromSegue(segue:UIStoryboardSegue) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")! as! SettingsTableViewCell
        cell.tvSensor.text = sensorNameList[indexPath.row]
        cell.ivSensor.image = sensorImgList[indexPath.row]
        cell.tvStatus.text = sensorStatusList[indexPath.row]
        cell.ivConnect.image = sensorConnectList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(0 == indexPath.row){
            self.performSegue(withIdentifier: "SettingsToSensorIdentifier", sender: self)
        } else if (4 == indexPath.row) {
            self.performSegue(withIdentifier: "SettingsToCubeIdentifier", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TaskToTaskViewIdentifier") {
            //prepare for segue to the details view controller
            let destinationVC = segue.destination as! SensorViewController
            destinationVC.sensorIndex = (self.tableView.indexPathForSelectedRow?.row)!
        }
    }
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}
