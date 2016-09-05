//
//  SKHealthKitUtility.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/11/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation
import HealthKit

class SKHealthKitUtility: NSObject{
    
    var hkSupported: Bool?
    var healthStore: HKHealthStore?
    let bloodPressureType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
    let stepeCountType    = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    
    static let sharedInstance = SKHealthKitUtility()
    
    private override init() {
        
        super.init()
        
        healthStore   = HKHealthStore()
        hkSupported     = false
    }
    
    //MARK: StepsCount
    
    func retrieveStepCountBetween(startTime: NSDate, endTime: NSDate, completion: ((stepsRetrieved: [SKStepsCount]!) -> ())? ) {
        
        //   Define the Step Quantity Type
        let stepsCount = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamplesWithStartDate(startTime, endDate: endTime, options: HKQueryOptions.None)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: HKStatisticsOptions.CumulativeSum, anchorDate: endTime, intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
            } else {
                var stepsPerDay = [SKStepsCount]()
                
                for r in results!.statistics(){
                    let result = r
                    let quantity = result.sumQuantity()
                    let count = quantity!.doubleValueForUnit(HKUnit.countUnit())
                    //print("sample: \(result.startDate.description) : \(count)")
                    
                    let stepCount   = SKStepsCount()
                    stepCount.day   = result.startDate
                    stepCount.total = Int(count)
                    
                    stepsPerDay.append(stepCount)
                }
                
                completion?(stepsRetrieved: stepsPerDay)
            }
        }
        
        healthStore!.executeQuery(query)
    }
    
    //MARK: Blood Pressure data
    
    func retrieveBPDataBetween(startTime: NSDate, endTime: NSDate, completion: ((bpInfoCollection: [SKBloodPressure]!) -> ())? ) {
        
        //   Define the Step Quantity Type
        let bpInfoType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodPressureSystolic)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamplesWithStartDate(startTime, endDate: endTime, options: HKQueryOptions.None)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: bpInfoType!, quantitySamplePredicate: predicate, options: HKStatisticsOptions.DiscreteAverage, anchorDate: endTime, intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                print("An error has occured with the following description: \(error!.localizedDescription)")
            } else {
                var bpInfoPerDay = [SKBloodPressure]()
                
                for r in results!.statistics(){
                    let result = r
                    let quantity = result.averageQuantity()
                    let count = quantity!.doubleValueForUnit(HKUnit.millimeterOfMercuryUnit())
                    //print("sample: \(result.startDate.description) : \(count)")
                    
                    let bpInfo   = SKBloodPressure()
                    bpInfo.day   = result.startDate
                    bpInfo.total = Int(count)
                    
                    bpInfoPerDay.append(bpInfo)
                }
                
                completion?(bpInfoCollection: bpInfoPerDay)
            }
        }
        
        healthStore!.executeQuery(query)
    }
    
    
    
    //MARK:- Authorization
    
    func checkAuthorization (completion: (success: Bool)-> Void) {
        // Default to assuming that we're authorized
        
        if (NSClassFromString("HKHealthStore") != nil) { hkSupported = true }
        
        // if already asked for persmission once then just call the completion handler
        //if NSUserDefaults.standardUserDefaults().boolForKey(SKConstants.UDK_For_HealthKit_Permission_Requested) == true{
        //    completion(success:  true)
        //}else{
            
        // Do we have access to HealthKit on this device?
        if (hkSupported == true && HKHealthStore.isHealthDataAvailable()) {
            // We have to request each data type explicitly
            
            // 1. Set the types you want to read from HK Store
            var readingsSet = Set<HKObjectType>()
            readingsSet.insert(bloodPressureType!)
            readingsSet.insert(stepeCountType!)
            
            
            // 2.  Request HealthKit authorization
            healthStore!.requestAuthorizationToShareTypes(nil, readTypes: readingsSet) { (success, error) -> Void in
                
                if error == nil {
                    
                    dispatch_async(dispatch_get_main_queue(), self.enableBackgroundHealthMonitoring)

                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: SKConstants.UDK_For_HealthKit_Permission_Requested)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    completion(success: success)
                }else{
                    print("Error in HealthKit authorization: \(error?.localizedDescription)")
                    completion(success: false)
                }
            }
            
        }
        else
        {
            // 3. If the store is not available (for instance, iPad) return an error and don't go on.
            print("HealthKit is not available on this device")
            completion(success:false)
            return;
        }
        //}
        
        
    }
    
    
    func enableBackgroundHealthMonitoring(){
        
        let query = HKObserverQuery(sampleType: stepeCountType!, predicate: nil, updateHandler: self.stepsUpdateHandler)
        healthStore?.executeQuery(query)
        
        let query2 = HKObserverQuery(sampleType: bloodPressureType!, predicate: nil, updateHandler: self.bloodPressureUpdateHandler)
        healthStore?.executeQuery(query2)
        
        self.healthStore?.enableBackgroundDeliveryForType( self.bloodPressureType!, frequency: HKUpdateFrequency.Immediate, withCompletion: { (success, error) in
            
            if error == nil{
                NSLog("-- Enabled background query for Blood Pressure")
                //SKHealthKitUtility.sharedInstance.listenForBloodPressureUpdates()
            }
        })
        
        self.healthStore?.enableBackgroundDeliveryForType( self.stepeCountType!, frequency: HKUpdateFrequency.Hourly, withCompletion: { (success, error) in
            if error == nil {
                NSLog("-- Enabled background query for Steps")
                //SKHealthKitUtility.sharedInstance.listenForStepsUpdates()
            }
        })
    }
    
    func stepsUpdateHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?){
        
        if (error == nil) {
            SKDBManager.sharedInstance.syncCloudDataForStepsCount( completion:  {
                print("Health update for steps")
                completionHandler()
            })
        } else {
            print("observer query returned error: \(error)")
        }
    }
    
    func bloodPressureUpdateHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?) {
        
        if (error == nil) {
            SKDBManager.sharedInstance.syncCloudDataForBloodPressure(completion: {
                print("Health update for bloodpressure")
                completionHandler()
            })
        } else {
            print("observer query returned error: \(error)")
        }
        
    }
    
    
}
