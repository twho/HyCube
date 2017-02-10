//
//  AddTaskViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/1/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit
import DropDown

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    var mainChannelName: String = "HyCubeTask4"
    let freqDropDown = DropDown()
    let assignDropDown = DropDown()
    let sensorDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.freqDropDown,
            self.assignDropDown,
            self.sensorDropDown
        ]
    }()

    @IBOutlet weak var edTaskName: UITextField!
    @IBOutlet weak var edTaskFreq: UITextField!
    @IBOutlet weak var edTaskAssign: UITextField!
    @IBOutlet weak var edTaskSensor: UITextField!
    @IBOutlet weak var btnSave: BorderedButton!
    
    let imgSaveClicked = (UIImage(named: "ic_check")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgSave = (UIImage(named: "ic_check")?.maskWithColor(color: UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0))!)! as UIImage
    let freqPickerArray = ["", ""]
    let assignPickerArray = [""]
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSave.setImage(imgSaveClicked, for: .highlighted)
        btnSave.setImage(imgSave, for: .normal)
        self.edTaskName.delegate = self
        self.edTaskFreq.delegate = self
        self.edTaskAssign.delegate = self
        self.edTaskSensor.delegate = self
        self.edTaskName.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
        self.freqDropDown.dataSource = ["Every week", "Every other week", "Every other month"]
        self.assignDropDown.dataSource = defaults.array(forKey: "myFriendsName") as! [String]
        self.sensorDropDown.dataSource = ["Kitchen sensor", "Living Room sensor", "Bathroom sensor", "Sink sensor"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSavePressed(_ sender: BorderedButton) {
        if(edTaskName.text!.characters.count > 0 && edTaskName.text!.characters.count > 0) {
            let message : [String : AnyObject] = ["uuid" : UUID().uuidString as AnyObject, "taskName" : edTaskName.text! as AnyObject, "taskFreq" : edTaskFreq.text! as AnyObject, "taskAssign" : edTaskAssign.text! as AnyObject, "taskSensor" : edTaskSensor.text! as AnyObject]
            appDelegate.client.publish(message, toChannel: mainChannelName, withCompletion: nil)
            self.performSegue(withIdentifier: "AddToTaskIdentifier", sender: self)
        } else {
            showAlert(error: "Cannot sumbit blank task")
        }
    }
   
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == self.edTaskFreq) {
            customizeDropDown(freqDropDown)
            freqDropDown.show()
            return false
        } else if (textField == self.edTaskAssign) {
            customizeDropDown(assignDropDown)
            assignDropDown.show()
            return false
        } else if (textField == self.edTaskSensor) {
            customizeDropDown(sensorDropDown)
            sensorDropDown.show()
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.edTaskName {
            self.edTaskFreq.becomeFirstResponder()
        } else if textField == self.edTaskFreq{
            self.edTaskAssign.becomeFirstResponder()
        } else {
            self.edTaskSensor.becomeFirstResponder()
        }
        return true
    }
    
    func customizeDropDown(_ sender: AnyObject) {
        view.endEditing(true)
        let appearance = DropDown.appearance()
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = edTaskSensor.textColor!
        appearance.direction = .any
        
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownListCell", bundle: nil)
            
            $0.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                guard cell is DropDownListCell else { return }
            }
        }
    
        freqDropDown.selectionAction = { [unowned self] (index, item) in
            self.edTaskFreq.text = self.freqDropDown.dataSource[index]
        }
        assignDropDown.selectionAction = { [unowned self] (index, item) in
            self.edTaskAssign.text = self.assignDropDown.dataSource[index]
        }
        sensorDropDown.selectionAction = { [unowned self] (index, item) in
            self.edTaskSensor.text = self.sensorDropDown.dataSource[index]
        }
    }
    
    func showAlert(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
