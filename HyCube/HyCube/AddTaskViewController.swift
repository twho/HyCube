//
//  AddTaskViewController.swift
//  HyCube
//
//  Created by Michael Ho on 12/1/16.
//  Copyright © 2016 hycube.com. All rights reserved.
//

import UIKit

protocol PassTaskItemBackDelegate: class {
    func passTaskItemBack(_ taskItem: TaskItem)
}

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: PassTaskItemBackDelegate?
    var popDatePicker: PopDatePicker?
    var mainChannelName: String = "HyCubeTask3"
    
    @IBOutlet weak var edTaskName: UITextField!
    @IBOutlet weak var edDueDate: UITextField!
    @IBOutlet weak var btnSave: BorderedButton!
    
    let imgSaveClicked = (UIImage(named: "ic_check")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgSave = (UIImage(named: "ic_check")?.maskWithColor(color: UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0))!)! as UIImage
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popDatePicker = PopDatePicker(forTextField: edDueDate)
        btnSave.setImage(imgSaveClicked, for: .highlighted)
        btnSave.setImage(imgSave, for: .normal)
        self.edTaskName.delegate = self
        self.edDueDate.delegate = self
        self.edTaskName.becomeFirstResponder()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSavePressed(_ sender: BorderedButton) {
        if(edTaskName.text!.characters.count > 0 && edTaskName.text!.characters.count > 0) {
//            uploadTask(taskName: edTaskName.text!, dueDate: edDueDate.text!, taskImg: imgSave)
            let message : [String : AnyObject] = ["uuid" : UUID().uuidString as AnyObject, "taskItem" : edTaskName.text! as AnyObject]
            appDelegate.client.publish(message, toChannel: mainChannelName, withCompletion: nil)
            self.performSegue(withIdentifier: "AddToTaskIdentifier", sender: self)
        } else {
            showAlert(error: "Cannot sumbit blank task")
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == self.edDueDate) {
            edDueDate.resignFirstResponder()
            view.endEditing(true)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let initDate : Date? = formatter.date(from: "Jan 09, 1980")
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
                forTextField.text = formatter.string(from: newDate)
            }
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.edTaskName {
            self.edDueDate.becomeFirstResponder()
        } else if textField == self.edDueDate{
            self.edTaskName.becomeFirstResponder()
        }
        return true
    }
    
    func uploadTask(taskName: String, dueDate: String, taskImg: UIImage){
        var request = URLRequest(url: URL(string: "http://140.118.7.117/hycube_ws/post_tasks.php")!)
        request.httpMethod = "POST"
        let postString = "task=\(taskName)&due_date=\(dueDate)&if_cleaned=0"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            //need to be checked
            print("\(responseString!)" == "InsertSuccess")
        }
        task.resume()
    }
    
    func showAlert(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
