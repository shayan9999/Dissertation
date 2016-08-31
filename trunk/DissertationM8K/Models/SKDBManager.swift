//
//  SKDBManager.swift
//  DissertationM8K
//
//  Created by Shayan K. on 7/25/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import UIKit
import CloudKit
import Datez

class SKDBManager: NSObject {
    
    //var dynamoDBManager: AWSDynamoDBObjectMapper?;
    
    //static var _sharedInstance: SKDBManager?
    
    static let sharedInstance = SKDBManager()
    
    private override init(){}

    //MARK:- CloudKit: Room Movement Section
    
    // Function to update ending Time Entry for the last room
    
    #if PATIENTAPP
    
        // Writes end time for the last room when a new room is discoverd
        func writeEndTimeForLastRoom (){
            
            // if there is an entry recordID that needs end time updating, update its end time now
            if let lastEntryName: String = NSUserDefaults.standardUserDefaults().objectForKey(SKConstants.UDK_For_CloudKit_Last_Room_Data_ID) as? String {
                
                let lastRecordID = CKRecordID.init(recordName: lastEntryName)
                
                self.getPublicDB().fetchRecordWithID(lastRecordID, completionHandler: { (recordForLastRoom, error) in
                    if let fetchError = error {
                        NSLog("Could not fetch Last Room Entry ID: %@", fetchError.localizedDescription)
                        assertionFailure()
                    }else{
                        recordForLastRoom?.setObject(NSDate.init(), forKey: "end_time");
                        self.getPublicDB().saveRecord(recordForLastRoom!, completionHandler: { (recordSaved, error) in
                            if let fetchError2 = error{
                                NSLog("Could not save Last Room end_date. Description: %@", fetchError2.localizedDescription)
                                //assertionFailure()
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

            // 1. Create a new RoomData entry
            // 2. Save Name + Start Date
            // 3. Keep log of the new recordID (to update its end time later)
            let roomData = CKRecord(recordType: SKConstants.ICloud_Table_Name_For_Room_Data)
            roomData[SKRoomData.tableKeyForName()] = roomName
            roomData[SKRoomData.tableKeyForStartTime()] = roomStartTime
            
            self.getPublicDB().saveRecord(roomData) { (recordForNewRoom, error) -> Void in
                
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
        
        
        //MARK:- CloudKit: HealthKit Data
        func syncCloudDataForStepsCount(){
            
            // To get all steps data we have before last written date
            //TODO: implement background monitoring of healthKit data on patient app.\
            
            var recordsToUpdate = [CKRecord]()
            
            if (SKHealthKitUtility.sharedInstance.checkAuthorization() == true){
                
                // if we have written data before
                let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate.init())
                var startDate    = startOfToday + (-12.days.timeInterval)
    
                if let startDayFromDefaults = NSUserDefaults.standardUserDefaults().objectForKey(SKConstants.UDK_For_CloudKit_Last_Step_Count_Day) as? NSDate{
                    
                    startDate = startDayFromDefaults
                }
                
                SKHealthKitUtility.sharedInstance.retrieveStepCountBetween(startDate, endTime: startOfToday, completion: { (stepsRetrieved) in
                    
                    let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_StepsCount, predicate: NSPredicate(format: "date >= %@ AND date =< %@", argumentArray: [startDate, startOfToday]))
                    self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
                        
                        if error == nil {
                            
                            // go through all the steps data received from healthKit
                            for stepInfo in stepsRetrieved {
                                
                                var foundMatch  = false
                                
                                // Go through all records rerieved from cloud
                                for result in results! {
                                    
                                    let dayForStepData   = result.objectForKey(SKBloodPressure.tableKeyForDay()) as! NSDate
                                    
                                    // If any data was already uploaded to cloud, update its values
                                    if stepInfo.day!.isEqualToDate(dayForStepData) {
                                        foundMatch = true
                                        result.setObject(stepInfo.total, forKey: SKBloodPressure.tableKeyForTotal())
                                        recordsToUpdate.append(result);
                                    }
                                }
                                
                                // if no match found, create a new record to add to the table
                                if foundMatch == false {
                                    let newRecordForStep = CKRecord.init(recordType: SKConstants.ICloud_Table_Name_For_StepsCount)
                                    newRecordForStep[SKBloodPressure.tableKeyForDay()] = stepInfo.day
                                    newRecordForStep[SKBloodPressure.tableKeyForTotal()] = stepInfo.total
                                    recordsToUpdate.append(newRecordForStep);
                                    
                                }
                            }
                            
                            // If there were some records found worth updating, update those records now
                            if recordsToUpdate.count > 0 {
                                let operation = CKModifyRecordsOperation.init(recordsToSave: recordsToUpdate, recordIDsToDelete: nil)
                                SKDBManager.sharedInstance.performCloudKitBulkOperation(operation);
                                NSUserDefaults.standardUserDefaults().setObject(startOfToday + -1.day.timeInterval, forKey: SKConstants.UDK_For_CloudKit_Last_Step_Count_Day)
                                NSUserDefaults.standardUserDefaults().synchronize()
                            }
                            
                        }else{
                            print(error?.localizedDescription)
                        }
                        
                    }
                    
                }) // completion block

            }
        }
    
    
        func syncCloudDataForBloodPressure(){
            
            // To get all steps data we have before last written date
            var recordsToUpdate = [CKRecord]()
            
            if (SKHealthKitUtility.sharedInstance.checkAuthorization() == true){
                
                // if we have written data before
                let startOfToday = NSCalendar.currentCalendar().startOfDayForDate(NSDate.init())
                var startDate    = startOfToday + (-12.days.timeInterval)
                
                if let startDayFromDefaults = NSUserDefaults.standardUserDefaults().objectForKey(SKConstants.UDK_For_CloudKit_Last_Blood_Pressure_Day) as? NSDate{
                    
                    startDate = startDayFromDefaults
                }
                
                //TODO: Create similar function for BP
                SKHealthKitUtility.sharedInstance.retrieveBPDataBetween(startDate, endTime: startOfToday, completion: { (bpInfoReceived) in
                    
                    let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_BloodPressure, predicate: NSPredicate(format: "date >= %@ AND date =< %@", argumentArray: [startDate, startOfToday]))
                    self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
                        
                        if error == nil {
                            
                            // go through all the steps data received from healthKit
                            for bpInfo in bpInfoReceived {
                                
                                var foundMatch  = false
                                
                                // Go through all records rerieved from cloud
                                for result in results! {
                                    
                                    let dayForBPData   = result.objectForKey(SKBloodPressure.tableKeyForDay()) as! NSDate
                                    
                                    // If any data was already uploaded to cloud, update its values
                                    if bpInfo.day!.isEqualToDate(dayForBPData) {
                                        foundMatch = true
                                        result.setObject(bpInfo.total, forKey: SKBloodPressure.tableKeyForTotal())
                                        recordsToUpdate.append(result);
                                    }
                                }
                                
                                // if no match found, create a new record to add to the table
                                if foundMatch == false {
                                    let newRecordForStep = CKRecord.init(recordType: SKConstants.ICloud_Table_Name_For_BloodPressure)
                                    newRecordForStep[SKBloodPressure.tableKeyForDay()] = bpInfo.day
                                    newRecordForStep[SKBloodPressure.tableKeyForTotal()] = bpInfo.total
                                    recordsToUpdate.append(newRecordForStep);
                                    
                                }
                            }
                            
                            // If there were some records found worth updating, update those records now
                            if recordsToUpdate.count > 0 {
                                let operation = CKModifyRecordsOperation.init(recordsToSave: recordsToUpdate, recordIDsToDelete: nil)
                                SKDBManager.sharedInstance.performCloudKitBulkOperation(operation);
                                NSUserDefaults.standardUserDefaults().setObject(startOfToday + -1.day.timeInterval, forKey: SKConstants.UDK_For_CloudKit_Last_Blood_Pressure_Day)
                                NSUserDefaults.standardUserDefaults().synchronize()
                            }
                            
                        }else{
                            print(error?.localizedDescription)
                        }
                        
                    }
                    
                }) // completion block
                
            }
        }
    
    #endif
    
    #if CARETAKERAPP
    
    func getPatientStepsCountData(completion: ((stepsRetrieved: [SKStepsCount]!) -> ())?){
    
        let sortDescriptor  = NSSortDescriptor(key: SKStepsCount.tableKeyForDay(), ascending: false)
    
        var stepsPerDay  = [SKStepsCount]()
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_StepsCount, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            
            for result in results!{
                let dayForStepData      = result.objectForKey(SKStepsCount.tableKeyForDay()) as! NSDate
                let totalForStepData    = result.objectForKey(SKStepsCount.tableKeyForTotal()) as! NSInteger
                let stepCountData       = SKStepsCount()
                stepCountData.day       = dayForStepData
                stepCountData.total     = totalForStepData
                stepsPerDay.append(stepCountData);
            }
            
            completion?(stepsRetrieved: stepsPerDay)
            
        }
        
    }
    
    
    func getPatientBloodPressureData(completion: ((bpInfoReceived: [SKBloodPressure]!) -> ())?){
        
        let sortDescriptor  = NSSortDescriptor(key: SKBloodPressure.tableKeyForDay(), ascending: false)
        
        var stepsPerDay  = [SKBloodPressure]()
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_BloodPressure, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            
            for result in results!{
                let dayForBP      = result.objectForKey(SKStepsCount.tableKeyForDay()) as! NSDate
                let totalForBP    = result.objectForKey(SKStepsCount.tableKeyForTotal()) as! NSInteger
                let bpData       = SKBloodPressure()
                bpData.day       = dayForBP
                bpData.total     = totalForBP
                stepsPerDay.append(bpData);
            }
            
            completion?(bpInfoReceived: stepsPerDay)
            
        }
        
    }
    
    #endif
    
    //MARK:- CloudKit: Triggers
    
    // Function to scan all triggers from iCloud
    func getAllTiggers(){
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_Triggers, predicate: NSPredicate(value: true));
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            if error == nil {
                print("Record Found: " + results!.description)
            }
            else{
                print(error?.localizedDescription)
            }
            
        }
        
    }
    
    //MARK:- CloudKit: Encouragements
    
    func saveEncouragement(encouragement: SKEncouragement, completion: (success: Bool)-> Void){
        
        let newRecord = CKRecord.init(recordType: SKConstants.ICloud_Table_Name_For_Encouragements)
        newRecord[SKEncouragement.tableKeyForName()] = encouragement.name
        newRecord[SKEncouragement.tableKeyForTimeOfDay()] = encouragement.timeofDay
        newRecord[SKEncouragement.tableKeyForTiming()] = encouragement.timing?.rawValue
        
        self.getPublicDB().saveRecord(newRecord, completionHandler: { (recordSaved, error) in
            if let fetchError2 = error{
                NSLog("Could not save Encouragement data. Description: %@", fetchError2.localizedDescription)
                completion(success: false)
            }else{
                NSLog("B. Saved Encouragement: ' %@ ' ", encouragement.name!)
                completion(success: true)
            }
        })
    }
    
    func getAllEncouragements(completion: ((encouragementsReceived: [SKEncouragement]!) -> ())?){
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_Encouragements, predicate: NSPredicate(value: true));
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            if error == nil {
                
                var encouragements = [SKEncouragement]()
                
                for result in results!{
                    let encouragement       = SKEncouragement()
                    encouragement.name      = result.objectForKey(SKEncouragement.tableKeyForName()) as? String
                    encouragement.timeofDay = result.objectForKey(SKEncouragement.tableKeyForTimeOfDay()) as? NSDate
                    let timingOption        = result.objectForKey(SKEncouragement.tableKeyForTiming()) as? NSInteger
                    encouragement.timing    = SKEncouragementDataTiming(rawValue: timingOption!)
                    encouragements.append(encouragement)
                }
                
                completion?(encouragementsReceived: encouragements)
            }
            else{
                print(error?.localizedDescription)
            }
            
        }
        
    }
    
    //MARK:- CareTaker App Functions
    
    func getRoomMovementDataForDate(theDate: NSDate, completion: ((roomDataReceived: [SKRoomData]!) -> Void)?){
                
        let queryPredicate  = self.predicateForDayFromDate(theDate)
        let sortDescriptor  = NSSortDescriptor(key: SKRoomData.tableKeyForStartTime(), ascending: true)
        
        let query           = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_Room_Data, predicate: queryPredicate);
        query.sortDescriptors = [sortDescriptor]
        
        var roomDataArray   = [SKRoomData]()
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            
            if error == nil {
                var i = 0
                if let recordsArray: [CKRecord]? = results {
                    
                    for record in recordsArray!{
                        
                        let roomData = SKRoomData.init()
                        roomData.name       = record.objectForKey(SKRoomData.tableKeyForName()) as? String
                        roomData.end_time   = record.objectForKey(SKRoomData.tableKeyForEndTime()) as? NSDate
                        roomData.start_time = record.objectForKey(SKRoomData.tableKeyForStartTime()) as? NSDate
                        
                        roomDataArray.append(roomData)
                        
                        i = i+1
                    }
                    
                }
    
            }
            else{
                print(error?.localizedDescription)
            }
         
            
            completion?(roomDataReceived: roomDataArray)
        }
        
    }
    
    //MARK:- Utility Method
    
    // returns public database from the pertinent container for the current app
    func getPublicDB()-> CKDatabase {
        let dbContainer = CKContainer(identifier: SKConstants.ICloud_Container_Name_For_App)
        let publicDB  = dbContainer.publicCloudDatabase
        
        return publicDB
    }
    
    // Set up subscriptions for cloud database changes
    // Use case: New Triggers added by Caretaker, New Encouragements added by CareTaker
    
    func setupCloudKitSubscriptions(){
        
        let alreadySet = NSUserDefaults.standardUserDefaults().boolForKey(SKConstants.UDK_For_CloudKit_Changes_Notifications)
        
        if alreadySet == false{
            
            // Adding Suscription for Encouagement table when any new data is added
            
            let predicate         = NSPredicate(value: true)
            let subscription = CKSubscription(recordType: SKConstants.ICloud_Table_Name_For_Encouragements, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
            
            let notificationInfo = CKNotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo
            
            self.getPublicDB().saveSubscription(subscription, completionHandler: { (sub, error) in
                
                if error != nil{
                    print(error?.localizedDescription)
                    //assertionFailure()
                }else{
                    print("### Saved Encouragements ADDITION subscription")
                }
                
            })
            
            // Adding Suscription for Encouagement table when any data is deleted
            
            let subscription2 = CKSubscription(recordType: SKConstants.ICloud_Table_Name_For_Encouragements, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordDeletion)
            subscription2.notificationInfo = notificationInfo
            
            self.getPublicDB().saveSubscription(subscription2, completionHandler: { (sub, error) in
                
                if error != nil{
                    print(error?.localizedDescription)
                    //assertionFailure()
                }else{
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: SKConstants.UDK_For_CloudKit_Changes_Notifications)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    print("### Saved Encouragements DELETION subscription")
                }
                
            })
            
        }
    }

    
    // Removes all subscriptions on cloud data changes
    func removeAllCloudKitSubscriptions(){

        var idsToDelete: [String] = [String]()
        
        self.getPublicDB().fetchAllSubscriptionsWithCompletionHandler({subscriptions, error in
            for subscriptionObject in subscriptions! {
                let subscription: CKSubscription = subscriptionObject as CKSubscription
                print(subscription.description)
                idsToDelete.append(subscriptionObject.subscriptionID)
            }
            
            let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: nil, subscriptionIDsToDelete: idsToDelete)
            self.getPublicDB().addOperation(modifyOperation)
        })
    }
    
    func predicateForDayFromDate(date: NSDate) -> NSPredicate {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar!.dateFromComponents(components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar!.dateFromComponents(components)
        
        return NSPredicate(format: "start_time >= %@ AND start_time =< %@", argumentArray: [startDate!, endDate!])
    }
    
    func performCloudKitBulkOperation(operation: CKModifyRecordsOperation){
        
        operation.perRecordCompletionBlock = {(record: CKRecord?, error: NSError?) -> Void in
            NSLog("Saved Record: %@", record!.recordID)
        }
        
        //Start operation
        self.getPublicDB().addOperation(operation)
    }

}
