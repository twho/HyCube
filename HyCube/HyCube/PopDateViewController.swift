//
//  PopDateViewController.swift
//  CARt
//
//  Created by Michael Ho on 11/22/16.
//  Copyright © 2016 cartrides.org. All rights reserved.
//

import UIKit

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(_ date : Date?)
}

class PopDateViewController: UIViewController {
    @IBOutlet var container: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnOkay: BorderedButton!
    
    weak var delegate : DataPickerViewControllerDelegate?
    
    let imgOkayClicked = (UIImage(named: "ic_check")?.maskWithColor(color: UIColor.white)!)! as UIImage
    let imgOkay = (UIImage(named: "ic_check")?.maskWithColor(color: UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0))!)! as UIImage
    
    var currentDate : Date? {
        didSet {
            updatePickerCurrentDate()
        }
    }
    
    convenience init() {
        self.init(nibName: "PopDateViewController", bundle: nil)
    }
    
    private func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _datePicker = self.datePicker {
                _datePicker.date = _currentDate
            }
        }
    }
    
    @IBAction func okAction(_ sender: BorderedButton) {
        self.dismiss(animated: true){
            let ndate = self.datePicker.date
            self.delegate?.datePickerVCDismissed(ndate)
        }
    }
    
    override func viewDidLoad() {
        updatePickerCurrentDate()
        btnOkay.setImage(imgOkay, for: .normal)
        btnOkay.setImage(imgOkayClicked, for: .highlighted)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.delegate?.datePickerVCDismissed(nil)
    }
}
