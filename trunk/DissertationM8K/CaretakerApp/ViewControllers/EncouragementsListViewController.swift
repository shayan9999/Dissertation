//
//  SKEncouragementsListViewController.swift
//  DissertationM8K
//
//  Created by Shayan K. on 9/4/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation
import SVProgressHUD

class EncouragementListCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    weak var actionListener: EncouragementsListViewController?
    
    @IBAction func deleteEncouragement(){
        actionListener?.deleteEncouragementAtIndex(self.tag)
    }
}

class EncouragementsListViewController : UITableViewController {
    
    var allEncouragements: NSArray?
    var shortDateFormatter: NSDateFormatter!
    var longDateFormatter: NSDateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Manage Encouragements"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        shortDateFormatter = NSDateFormatter()
        longDateFormatter  = NSDateFormatter()
        
        longDateFormatter.dateFormat    = "MMM dd hh:mm a"
        shortDateFormatter.dateFormat   = "hh:mm a"
        
        self.view.backgroundColor = UIColor.colorFromHex("#393939")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        // Loading encouragements before allowing touch
        SVProgressHUD.showWithStatus("Loading...")
        self.loadAllEncouragements()
    }
    
    //MARK:- Utility methods
    
    func loadAllEncouragements(){
                
        SKDBManager.sharedInstance.getAllEncouragements { (encouragementsReceived) in
            
            self.allEncouragements = NSArray.init(array: encouragementsReceived)
            dispatch_async(dispatch_get_main_queue(), {
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            })
        }
    }
    
    //MARK:- Table View Data Source
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            self.deleteEncouragementAtIndex(indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allEncouragements?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var currentDateFormatter: NSDateFormatter? = shortDateFormatter
        
        let encouragement: SKEncouragement = allEncouragements?.objectAtIndex(indexPath.row) as! SKEncouragement
        let cell:EncouragementListCell = self.tableView.dequeueReusableCellWithIdentifier(SKConstants.Cell_Identifier_For_Encouragements) as! EncouragementListCell
        
        if encouragement.timing?.hasAssociatedDay() == true {
            currentDateFormatter = longDateFormatter
        }
        
        let timingString: String = encouragement.timing?.timingPrefix ?? ""
        let dateString: String   = currentDateFormatter?.stringFromDate(encouragement.timeofDay!) ?? ""
        
        cell.title.text     = timingString + dateString
        cell.detail.text    = encouragement.name
        cell.tag            = indexPath.row
        cell.actionListener = self
        
        cell.sizeToFit()
        cell.detail.sizeToFit()
        
        return cell
    }
    
    // MARK:- Cell actionsListener
    
    func deleteEncouragementAtIndex (index: Int){
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this encouragement?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler:  nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive,
            handler: { (action: UIAlertAction!) in
                
            SVProgressHUD.showWithStatus("Loading...")
            let encouragementToDelete = self.allEncouragements?.objectAtIndex(index) as! SKEncouragement
            SKDBManager.sharedInstance.deleteEncouragement(encouragementToDelete) { (success) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadAllEncouragements()
                })
            }
                
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
}
