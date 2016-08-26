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
    var healthStorage: HKHealthStore?
    
    static let sharedInstance = SKHealthKitUtility()
    
    private override init() {
        
        super.init()
        
        healthStorage   = HKHealthStore()
        hkSupported     = false
    }
    
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
        
        healthStorage!.executeQuery(query)
    }
    
    //MARK:- Authorization
    
    func checkAuthorization () -> Bool {
        // Default to assuming that we're authorized
        var isEnabled = true
        
        if (NSClassFromString("HKHealthStore") != nil) { hkSupported = true }
        
        // Do we have access to HealthKit on this device?
        if (hkSupported == true && HKHealthStore.isHealthDataAvailable()) {
            // We have to request each data type explicitly
            
            // Ask for BG
            var readingsSet = Set<HKObjectType>()
            readingsSet.insert(HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBloodGlucose)!)
            readingsSet.insert(HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!)
            healthStorage!.requestAuthorizationToShareTypes(nil, readTypes: readingsSet) { (success, error) -> Void in
                isEnabled = success
                NSLog("Successfully enabled healthKit Data")
            }
            
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    
    
    
}
