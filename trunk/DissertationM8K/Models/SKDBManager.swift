//
//  SKDBManager.swift
//  DissertationM8K
//
//  Created by Shayan K. on 7/25/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import UIKit
import CloudKit

class SKDBManager: NSObject {
    
    var dynamoDBManager: AWSDynamoDBObjectMapper?;
    
    //static var _sharedInstance: SKDBManager?
    
    static let sharedInstance = SKDBManager()
    
    private override init(){}
    
//    static func sharedInstance() -> SKDBManager{
//        if _sharedInstance == nil {
//            _sharedInstance = SKDBManager.init()
//        }
//        return _sharedInstance!
//    }
    
    // initialize and connect to the online database at Amazon Web Services
    //override init(){
        //dynamoDBManager = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper();
        //super.init();
    //}
    
    // Set up subscriptions for cloud database changes
    
    func setupCloudKitSubscriptions(){
        
        let alreadySet = NSUserDefaults.standardUserDefaults().boolForKey(SKConstants.UDK_For_CloudKit_Changes_Notifications)
        
        if alreadySet == false{
            
            //let recordID  = CKRecordID(recordName: "1");
            
            //TODO: update this to map one patient to his caretaker
            //let predicate       = NSPredicate(format: "pair_id = %ld", 1)
            let predicate         = NSPredicate(value: true)
            let subscription = CKSubscription(recordType: SKConstants.ICloud_Table_Name_For_Triggers, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
            
            let notificationInfo = CKNotificationInfo()
            //notificationInfo.alertBody = "Your caretaker has added a new Trigger for you. Open the app to update settings now"
            //notificationInfo.shouldBadge = true
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo
            
            let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
            
            publicDatabase.saveSubscription(subscription, completionHandler: { (subscription, error) in
                
                if error != nil{
                    print(error?.localizedDescription)
                    //assertionFailure()
                }else{
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: SKConstants.UDK_For_CloudKit_Changes_Notifications)
                }
                
            })
            
        }
    }
    
    // Function to update ending Time Entry for the last room
    
    func writeEndTimeForLastRoom (){
        
        let dbContainer = CKContainer.defaultContainer()
        let publicDB  = dbContainer.publicCloudDatabase
        
        // if there is an entry recordID that needs end time updating, update its end time now
        if let lastEntryName: String = NSUserDefaults.standardUserDefaults().objectForKey(SKConstants.UDK_For_CloudKit_Last_Room_Data_ID) as? String {
            
            let lastRecordID = CKRecordID.init(recordName: lastEntryName)
            
            publicDB.fetchRecordWithID(lastRecordID, completionHandler: { (recordForLastRoom, error) in
                if let fetchError = error {
                    NSLog("Could not fetch Last Room Entry ID: %@", fetchError.localizedDescription)
                    assertionFailure()
                }else{
                    recordForLastRoom?.setObject(NSDate.init(), forKey: "end_time");
                    publicDB.saveRecord(recordForLastRoom!, completionHandler: { (recordSaved, error) in
                        if let fetchError2 = error{
                            NSLog("Could not save Last Room end_date. Description: %@", fetchError2.localizedDescription)
                            assertionFailure()
                        }else{
                            NSLog("B. Saved end time for last room record")
                        }
                    })
                }
            })
        }
    }
    
    
    // Function to write room movement information
    
    func writeNewRoomEntry(roomName: NSString, roomStartTime: NSDate){
        
        // First update end time for the last room
        SKDBManager.sharedInstance.writeEndTimeForLastRoom();
        
        let dbContainer = CKContainer.defaultContainer()
        let publicDB  = dbContainer.publicCloudDatabase
        
        // 1. Create a new RoomData entry
        // 2. Save Name + Start Date
        // 3. Keep log of the new recordID (to update its end time later)
        let roomData = CKRecord(recordType: SKConstants.ICloud_Table_Name_For_Room_Data)
        roomData["name"] = roomName
        roomData["start_time"] = roomStartTime
        
        publicDB.saveRecord(roomData) { (recordForNewRoom, error) -> Void in
            
            if let fetchError = error {
                 NSLog("Error in writing data to iCloud: " + fetchError.localizedDescription)
            }else{
                
                // if the new room entry was successfully stored, save its recordID for updating end time later
                if let newRoomRecordID = recordForNewRoom?.recordID{
                    NSUserDefaults.standardUserDefaults().setObject(newRoomRecordID.recordName, forKey: SKConstants.UDK_For_CloudKit_Last_Room_Data_ID)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                NSLog("A. Saved new room data")
            }
        }
    }
    
    // Function to scan all triggers from iCloud
    
    func getAllTiggers(){
        
        let dbContainer = CKContainer.defaultContainer()
        let publicData  = dbContainer.publicCloudDatabase
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_Triggers, predicate: NSPredicate(value: true));
        
        publicData.performQuery( query, inZoneWithID: nil) { (results, error) in
            if error == nil {
                print("Record Found: " + results!.description)
            }
            else{
                print(error?.localizedDescription)
            }
            
        }
        
        /*
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 20
        
        dynamoDBManager.scan( SKTrigger.self, expression:  scanExpression).continueWithSuccessBlock { (task: AWSTask) -> AnyObject? in
            
            if((task.result) != nil){
                let pagingOutput : AWSDynamoDBPaginatedOutput = task.result as! AWSDynamoDBPaginatedOutput;
                for item in pagingOutput.items{
                    let trigger = item as! SKTrigger;
                    print("Name: " + trigger.name);
                }
            }
            
            return nil;
        }
        */
        
    }
    
    //MARK: - Utility Method
    
    // Removes all subscriptions on cloud data changes 
    
    func removeAllCloudKitSubscriptions(){
        let database = CKContainer.defaultContainer().publicCloudDatabase
        var idsToDelete: [String] = [String]()
        
        database.fetchAllSubscriptionsWithCompletionHandler({subscriptions, error in
            for subscriptionObject in subscriptions! {
                let subscription: CKSubscription = subscriptionObject as CKSubscription
                print(subscription.description)
                idsToDelete.append(subscriptionObject.subscriptionID)
            }
            
            let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: idsToDelete)
            database.addOperation(modifyOperation)
        })
    }

}
