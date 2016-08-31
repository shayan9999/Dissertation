//
//  SettingsViewController.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/31/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation

class SettingsViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var criticalStepsCountTextField: UITextField!
    @IBOutlet weak var criticalBloodPressureTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Settings"
        
        let rightButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(pressedSave))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        criticalStepsCountTextField.text = NSString.localizedStringWithFormat("%d", SKConstants.getCriticalStepsCount()) as String
        criticalBloodPressureTextField.text = NSString.localizedStringWithFormat("%d", SKConstants.getCriticalBloodPressure()) as String
    }
    
    func pressedSave(){
        
        //TODO: Save the settings here
        
//        if encouragementText.text.isEmpty == true {
//            let alertController = SKNotificationsUtility.getSingleButtonAlertView(withTitle: "Enter Message", andMessage: "Please enter encouragement message")
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }else{
//            let newEncouragement            = SKEncouragement()
//            newEncouragement.name           = encouragementText.text
//            newEncouragement.timeofDay      = encouragementTime.date
//            newEncouragement.timing         = SKEncouragementDataTiming(rawValue: encouragementTiming.selectedSegmentIndex + 1)
//            
//            SVProgressHUD .showWithStatus("Sending..")
//            SKDBManager.sharedInstance.saveEncouragement(newEncouragement, completion: { (success) in
//                SVProgressHUD.dismiss()
//                if success == false {
//                    SKNotificationsUtility.getSingleButtonAlertView(withTitle: "Something went wrong", andMessage: "Could not save the encouragement to the database, please try again later")
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.navigationController?.popViewControllerAnimated(true)
//                    })
//                }
//            })
//            
//        }
    }
    
    @IBAction func hideKeyboard (){
        
        contactNumberTextField.resignFirstResponder()
        criticalStepsCountTextField.resignFirstResponder()
        criticalBloodPressureTextField.resignFirstResponder()
    }
    
    //MARK: UITextField Delegates
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}