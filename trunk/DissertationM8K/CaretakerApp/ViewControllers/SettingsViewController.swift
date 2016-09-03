//
//  SettingsViewController.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/31/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

class NoPasteTextField: UITextField {
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "paste:" {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class SettingsViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var contactNumberTextField           : UITextField!
    @IBOutlet weak var criticalStepsCountTextField      : UITextField!
    @IBOutlet weak var criticalBloodPressureTextField   : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Settings"
        
        let rightButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(pressedSave))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        contactNumberTextField.text = SKConstants.getCaretakerContactNumber()
        criticalStepsCountTextField.text = NSString.localizedStringWithFormat("%d", SKConstants.getCriticalStepsCount()) as String
        criticalBloodPressureTextField.text = NSString.localizedStringWithFormat("%d", SKConstants.getCriticalBloodPressure()) as String
    }
    
    func pressedSave(){
        
        self.hideKeyboard()
        
        if contactNumberTextField.text!.isEmpty{
            
            let alertController = SKNotificationsUtility.getSingleButtonAlertView(withTitle: "Enter Contact Number", andMessage: "Please enter the contact number to save")
            self.presentViewController(alertController, animated: true, completion: nil)
        
        }else if criticalStepsCountTextField.text!.isEmpty ||  criticalBloodPressureTextField.text!.isEmpty{
            // DO NOTHING
        }else{
            
            NSUserDefaults.standardUserDefaults().setObject(contactNumberTextField.text, forKey: SKConstants.UDK_For_Caretaker_Contact_Number)
            NSUserDefaults.standardUserDefaults().setObject(criticalStepsCountTextField.text, forKey: SKConstants.UDK_For_Step_Count_Critical_Level)
            NSUserDefaults.standardUserDefaults().setObject(criticalBloodPressureTextField.text, forKey: SKConstants.UDK_For_Blood_Pressure_Critical_Level)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            SVProgressHUD.showWithStatus("Saving settings to cloud...")
            
            let settings = SKSettings()
            settings.caretakerContact       = contactNumberTextField.text!
            settings.criticalStepsCount     = NSInteger.init(criticalStepsCountTextField.text!)
            settings.criticalBloodPressure  = NSInteger.init(criticalBloodPressureTextField.text!)
            
            SKDBManager.sharedInstance.saveSettings(settings) { (success) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                    
                    if success == false {
                        let alert = SKNotificationsUtility.getSingleButtonAlertView(withTitle: "Something went wrong", andMessage: "Could not save the settings to the iCloud, please try again later")
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else{
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
                
            }
        }
        
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