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
    
    //MARK:- Patient App Functions
    //MARK:-
    
    //MARK: CloudKit: Room Data Write

    // Writes end time for the last room when a new room is discoverd
    // Function to update ending Time Entry for the last room
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

    //MARK: CloudKit: HealthKit Data Write


    func authorizeAndSyncHealthKitData(){
        SKHealthKitUtility.sharedInstance.checkAuthorization(){ (success) in
            //Once user has been asked for permissions, start sync for blood pressure and steps data
            if success == true {
                //SKHealthKitUtility.sharedInstance.listenForStepsUpdates()
                //SKHealthKitUtility.sharedInstance.listenForBloodPressureUpdates()
                //SKDBManager.sharedInstance.syncCloudDataForStepsCount(completion: nil)
                //SKDBManager.sharedInstance.syncCloudDataForBloodPressure(completion: nil)
            }
        }
    }

    func syncCloudDataForStepsCount(completion completion: (() -> Void)? ){
        
        // To get all steps data we have before last written date
        //TODO implement background monitoring of healthKit data on patient app.\
        
        var recordsToUpdate = [CKRecord]()
        
        // if we have written data before
        let startOfNextDay = NSCalendar.currentCalendar().startOfDayForDate(NSDate.init() + 1.day.timeInterval)
        var startDate    = startOfNextDay + (-12.days.timeInterval)
        
        if let startDayFromDefaults = NSUserDefaults.standardUserDefaults().objectForKey(SKConstants.UDK_For_CloudKit_Last_Step_Count_Day) as? NSDate{
            
            startDate = startDayFromDefaults
        }
        
        SKHealthKitUtility.sharedInstance.retrieveStepCountBetween(startDate, endTime: startOfNextDay, completion: { (stepsRetrieved) in
            
            let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_StepsCount, predicate: NSPredicate(format: "date >= %@ AND date =< %@", argumentArray: [startDate, startOfNextDay]))
            self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
                
                if error == nil {
                    
                    // go through all the steps data received from healthKit
                    for stepInfo in stepsRetrieved {
                        
                        var foundMatch  = false
                        
                        // Go through all records rerieved from cloud
                        for result in results! {
                            
                            let dayForStepData   = result.objectForKey(SKStepsCount.tableKeyForDay()) as! NSDate
                            
                            // If any data was already uploaded to cloud, update its values
                            if stepInfo.day!.isEqualToDate(dayForStepData) {
                                foundMatch = true
                                let oldValue = result[SKStepsCount.tableKeyForTotal()] as? NSInteger
                                if oldValue != stepInfo.total {
                                    result.setObject(stepInfo.total, forKey: SKStepsCount.tableKeyForTotal())
                                    recordsToUpdate.append(result);
                                }
                            }
                        }
                        
                        // if no match found, create a new record to add to the table
                        if foundMatch == false {
                            let newRecordForStep = CKRecord.init(recordType: SKConstants.ICloud_Table_Name_For_StepsCount)
                            newRecordForStep[SKStepsCount.tableKeyForDay()] = stepInfo.day
                            newRecordForStep[SKStepsCount.tableKeyForTotal()] = stepInfo.total
                            recordsToUpdate.append(newRecordForStep);
                            
                        }
                    }
                    
                    // If there were some records found worth updating, update those records now
                    if recordsToUpdate.count > 0 {
                        let operation = CKModifyRecordsOperation.init(recordsToSave: recordsToUpdate, recordIDsToDelete: nil)
                        SKDBManager.sharedInstance.performCloudKitBulkOperation(operation, completion: nil)
                        NSUserDefaults.standardUserDefaults().setObject(startOfNextDay + -1.day.timeInterval, forKey: SKConstants.UDK_For_CloudKit_Last_Step_Count_Day)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    
                    completion?()
                    
                }else{
                    print(error?.localizedDescription)
                }
                
            }
            
        }) // completion block
        
    }

    func syncCloudDataForBloodPressure(completion completion: (() -> Void)? ){
    
        // To get all steps data we have before last written date
        var recordsToUpdate = [CKRecord]()
        
        // if we have written data before
        let startOfNextDay = NSCalendar.currentCalendar().startOfDayForDate(NSDate.init() + 1.day.timeInterval)
        var startDate    = startOfNextDay + (-12.days.timeInterval)
        
        if let startDayFromDefaults = NSUserDefaults.standardUserDefaults().objectForKey(SKConstants.UDK_For_CloudKit_Last_Blood_Pressure_Day) as? NSDate{
            
            startDate = startDayFromDefaults
        }
        
        SKHealthKitUtility.sharedInstance.retrieveBPDataBetween(startDate, endTime: startOfNextDay, completion: { (bpInfoReceived) in
            
            let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_BloodPressure, predicate: NSPredicate(format: "date >= %@ AND date =< %@", argumentArray: [startDate, startOfNextDay]))
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
                                let oldValue = result[SKBloodPressure.tableKeyForTotal()] as! NSInteger
                                if oldValue != bpInfo.total {
                                    result.setObject(bpInfo.total, forKey: SKBloodPressure.tableKeyForTotal())
                                    recordsToUpdate.append(result);
                                }
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
                        SKDBManager.sharedInstance.performCloudKitBulkOperation(operation, completion: nil)
                        NSUserDefaults.standardUserDefaults().setObject(startOfNextDay + -1.day.timeInterval, forKey: SKConstants.UDK_For_CloudKit_Last_Blood_Pressure_Day)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    
                    completion?()
                    
                }else{
                    print(error?.localizedDescription)
                }
                
            }
            
        }) // completion block
            
    }
    
    //MARK:- CareTaker App Functions
    //MARK:-
    
    //MARK: CloudKit: Health Data Fetch

    func getPatientStepsCountData(completion: (stepsRetrieved: [SKStepsCount]!) -> ()){
    
        let sortDescriptor  = NSSortDescriptor(key: SKStepsCount.tableKeyForDay(), ascending: false)
    
        var stepsPerDay  = [SKStepsCount]()
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_StepsCount, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            
            if error == nil {
                for result in results!{
                    let dayForStepData      = result.objectForKey(SKStepsCount.tableKeyForDay()) as! NSDate
                    let totalForStepData    = result.objectForKey(SKStepsCount.tableKeyForTotal()) as! NSInteger
                    let stepCountData       = SKStepsCount()
                    stepCountData.day       = dayForStepData
                    stepCountData.total     = totalForStepData
                    stepsPerDay.append(stepCountData);
                }
            }else{
                print(error?.localizedDescription)
            }
            
            completion(stepsRetrieved: stepsPerDay)
            
        }
        
    }
    
    func getPatientBloodPressureData(completion: (bpInfoReceived: [SKBloodPressure]!) -> ()){
        
        let sortDescriptor  = NSSortDescriptor(key: SKBloodPressure.tableKeyForDay(), ascending: false)
        
        var stepsPerDay  = [SKBloodPressure]()
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_BloodPressure, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            
            if error == nil {
                for result in results!{
                    let dayForBP      = result.objectForKey(SKStepsCount.tableKeyForDay()) as! NSDate
                    let totalForBP    = result.objectForKey(SKStepsCount.tableKeyForTotal()) as! NSInteger
                    let bpData       = SKBloodPressure()
                    bpData.day       = dayForBP
                    bpData.total     = totalForBP
                    stepsPerDay.append(bpData);
                }
            }else{
                print(error?.localizedDescription)
            }
            
            completion(bpInfoReceived: stepsPerDay)
            
        }
        
    }

    //MARK: CloudKit: Room Data Fetch

    func getPatientRoomMovementDataForDate(theDate: NSDate, completion: (roomDataReceived: [SKRoomData]!) -> Void){
        
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
            
            
            completion(roomDataReceived: roomDataArray)
        }
        
    }

    //MARK: CloudKit: Triggers Fetch
    
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

    
    //MARK: CloudKit: Encouragements
    //MARK:-
    
    func getAllEncouragements(completion: (encouragementsReceived: [SKEncouragement]!) -> ()){
        
        let query       = CKQuery(recordType: SKConstants.ICloud_Table_Name_For_Encouragements, predicate: NSPredicate(value: true));
        
        self.getPublicDB().performQuery( query, inZoneWithID: nil) { (results, error) in
            
            // returns empty array even if there is an error
            var encouragements = [SKEncouragement]()
            
            if error == nil {
                
                for result in results!{
                    
                    let encouragement       = SKEncouragement()
                    encouragement.name      = result.objectForKey(SKEncouragement.tableKeyForName()) as? String
                    encouragement.timeofDay = result.objectForKey(SKEncouragement.tableKeyForTimeOfDay()) as? NSDate
                    let timingOption        = result.objectForKey(SKEncouragement.tableKeyForTiming()) as? NSInteger
                    encouragement.timing    = SKEncouragementDataTiming(rawValue: timingOption!)
                    encouragement.recordID  = result.recordID
                    
                    encouragements.append(encouragement)
                }
            }
            else{
                print(error?.localizedDescription)
            }
            
            completion(encouragementsReceived: encouragements)
        }
        
    }
    
    func saveEncouragement(encouragement: SKEncouragement, completion: (success: Bool)-> Void){
        
        let newRecord = CKRecord.init(recordType: SKConstants.ICloud_Table_Name_For_Encouragements)
        newRecord[SKEncouragement.tableKeyForName()] = encouragement.name
        newRecord[SKEncouragement.tableKeyForTimeOfDay()] = encouragement.timeofDay
        newRecord[SKEncouragement.tableKeyForTiming()] = encouragement.timing?.rawValue
        
        self.getPublicDB().saveRecord(newRecord, completionHandler: { (recordSaved, error) in
            
            if error == nil{
                NSLog("B. Saved Encouragement: ' %@ ' ", encouragement.name!)
                completion(success: true)
            }else{
                NSLog("Could not save Encouragement data. Description: %@", error!.localizedDescription)
                completion(success: false)
            }
        })
    }
    
    
    func deleteEncouragement(encouragement: SKEncouragement, completion: (success: Bool)-> Void){
        
        let operation = CKModifyRecordsOperation.init(recordsToSave: nil, recordIDsToDelete: [encouragement.recordID])
        
        SKDBManager.sharedInstance.performCloudKitBulkOperation(operation, completion: { (bulkOperationCompletion) in
            if bulkOperationCompletion == true {
                completion(success: true)
            }else{
                completion(success: false)
            }
        })
        
    }

    
    
    //MARK:- CloudKit: Settings
    //MARK:
    
    func saveSettings(setting: SKSettings, completion: (success: Bool)-> Void){
        
        
        let database = self.getPublicDB()
        let recordID = CKRecordID(recordName: SKConstants.ICloud_Record_Name_For_Settings)
        
        database.fetchRecordWithID(recordID) { (record, error) in
            
            if error == nil {
                
                record![SKSettings.tableKeyForCaretakerContact()] = setting.caretakerContact
                record![SKSettings.tableKeyForCriticalStepsCount()] = setting.criticalStepsCount
                record![SKSettings.tableKeyForCriticalBloodPressure()] = setting.criticalBloodPressure
                
                
                database.saveRecord(record!, completionHandler: { (recordSaved, error) in
                    if let fetchError = error{
                        NSLog("Could not save Setting data. Description: %@", fetchError.localizedDescription)
                        completion(success: false)
                    }else{
                        NSLog("B. Saved Setting to record name: ' %@ ' ", recordSaved!.recordID.recordName)
                        completion(success: true)
                    }
                })
            }
            else{
                print(error?.localizedDescription)
            }
        }
    }
    
    func getAppSettings(completion: ((settingsReceived: SKSettings?) -> ())?) {
        
        let recordID                = CKRecordID(recordName: SKConstants.ICloud_Record_Name_For_Settings)
        var settings: SKSettings?   = nil
        
        self.getPublicDB().fetchRecordWithID(recordID) { ( record, error) in
            if error == nil {
                
                settings = SKSettings()
                
                settings!.caretakerContact   = record?.objectForKey(SKSettings.tableKeyForCaretakerContact()) as? String
                settings!.criticalStepsCount = record?.objectForKey(SKSettings.tableKeyForCriticalStepsCount()) as? NSInteger
                settings!.criticalBloodPressure = record?.objectForKey(SKSettings.tableKeyForCriticalBloodPressure()) as? NSInteger
                
                completion?(settingsReceived: settings)
            }
            else{
                print(error?.localizedDescription)
            }
        }
    }

    
    //MARK:- Utility Method
    //MARK:-
    
    // returns public database from the pertinent container for the current app
    func getPublicDB()-> CKDatabase {
        let dbContainer = CKContainer(identifier: SKConstants.ICloud_Container_Name_For_App)
        let publicDB  = dbContainer.publicCloudDatabase
        
        return publicDB
    }
    
    // Set up subscriptions for cloud database changes
    // Use case: New Triggers added by Caretaker, New Encouragements added by CareTaker
    // Adding Suscription for Encouagement table when any new data is added or any item is deleted
    
    func setupCloudKitSubscriptions(){
        
        let alreadySet = NSUserDefaults.standardUserDefaults().boolForKey(SKConstants.UDK_For_CloudKit_Changes_Notifications)
        
        if alreadySet == true {
            return
        }
                    
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        let predicate         = NSPredicate(value: true)
        
        // Defining subscription types here
        let additionSub = CKSubscription(recordType: SKConstants.ICloud_Table_Name_For_Encouragements, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        additionSub.notificationInfo = notificationInfo
        
        let deletionSub = CKSubscription(recordType: SKConstants.ICloud_Table_Name_For_Encouragements, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordDeletion)
        deletionSub.notificationInfo = notificationInfo
        
        
        
        let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [additionSub, deletionSub], subscriptionIDsToDelete: nil)
        self.getPublicDB().addOperation(modifyOperation)
        
        modifyOperation.modifySubscriptionsCompletionBlock = {(savedSubs, deletedSubs, error) in
            if error == nil{
                
                for savedSub in savedSubs! {
                    if savedSub.subscriptionID == additionSub.subscriptionID {
                        print("### Saved Encouragements ADDITION subscription")
                    }else if savedSub.subscriptionID == deletionSub.subscriptionID {
                        print("### Saved Encouragements DELETION subscription")
                    }
                }
                
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: SKConstants.UDK_For_CloudKit_Changes_Notifications)
                NSUserDefaults.standardUserDefaults().synchronize()
                
            }else{
                
                if(error?.code == CKErrorCode.PartialFailure.rawValue){
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: SKConstants.UDK_For_CloudKit_Changes_Notifications)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                print(error?.localizedDescription)
            }
            
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
    
    func performCloudKitBulkOperation(operation: CKModifyRecordsOperation, completion: ((success: Bool)-> Void)? ){
        
        operation.perRecordCompletionBlock = {(record, error) -> Void in
            
            if error == nil{
                NSLog("Saved Record for Type: %@", record!.recordType)
            }else{
                print(error?.localizedDescription)
            }
        }
        
        operation.modifyRecordsCompletionBlock = {(savedRecords, deletedRecords, error) in
            if savedRecords?.count == operation.recordsToSave?.count {
                completion?(success: true)
            }else{
                completion?(success: false)
            }
            
        }
        
        //Start operation
        self.getPublicDB().addOperation(operation)
    }

}
