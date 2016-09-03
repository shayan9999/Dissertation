//
//  EncouragementsViewController.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/28/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation
import SVProgressHUD

class EncouragementsViewController: UIViewController, UITextViewDelegate{
    
    @IBOutlet weak var vibrancyEffectView: UIVisualEffectView!
    
    @IBOutlet weak var encouragementText: UITextView!
    @IBOutlet weak var encouragementTiming: UISegmentedControl!
    @IBOutlet weak var encouragementTime: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Steps Per Day"
        
        let rightButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(pressedSave))
        self.navigationItem.rightBarButtonItem = rightButton
        
        
        vibrancyEffectView.layer.cornerRadius = 8.0
        encouragementTiming.selectedSegmentIndex = 0
    
    }
    
    //MARK:- UI Interactions
    
    func pressedSave(){
        if encouragementText.text.isEmpty == true {
            
            let alertController = SKNotificationsUtility.getSingleButtonAlertView(withTitle: "Enter Message", andMessage: "Please enter encouragement message")
            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            
            let newEncouragement            = SKEncouragement()
            newEncouragement.name           = encouragementText.text
            newEncouragement.timeofDay      = encouragementTime.date
            newEncouragement.timing         = SKEncouragementDataTiming(rawValue: encouragementTiming.selectedSegmentIndex + 1)
            
            SVProgressHUD .showWithStatus("Sending..")
            SKDBManager.sharedInstance.saveEncouragement(newEncouragement, completion: { (success) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                    
                    if success == false {
                        let alert = SKNotificationsUtility.getSingleButtonAlertView(withTitle: "Something went wrong", andMessage: "Could not save the encouragement to the database, please try again later")
                        self.presentViewController(alert, animated: true, completion: nil)
                    }else{
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                })
            })
            
        }
    }
    
    //MARK:- Text View Delegates
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false;
        }else{
            return true;
        }
    }
    
}
