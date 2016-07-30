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
    
    // initialize and connect to the online database at Amazon Web Services
    //override init(){
        //dynamoDBManager = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper();
        //super.init();
    //}
    
    // Scans all values from the online database
    
    func setupNotifications(){
        let alreadySet = NSUserDefaults.standardUserDefaults().boolForKey(Constants.UDK_For_CloudKit_Changes_Notifications)
        
        if alreadySet == false{
            
            //let recordID  = CKRecordID(recordName: "1");
            
            //TODO: update this to map one patient to his caretaker
            let predicate       = NSPredicate(format: "pair_id = %ld", 1)
            let subscription = CKSubscription(recordType: "Triggers", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
            
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
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.UDK_For_CloudKit_Changes_Notifications)
                }
                
            })
            
        }
    }
    
    func scanAllValues(){
        
        let dbContainer = CKContainer.defaultContainer()
        let publicData  = dbContainer.publicCloudDatabase
        
        let query       = CKQuery(recordType: "Triggers", predicate: NSPredicate(value: true));
        
        publicData.performQuery( query, inZoneWithID: nil) { (results, error) in
            if error == nil {
                print("Record Found: " + results!.description)
            }
            else{
                print(error?.localizedDescription)
                assertionFailure()
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
