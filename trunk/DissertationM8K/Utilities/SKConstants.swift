//
//  Constants.swift
//  DissertationM8K
//
//  Created by Shayan K. on 7/17/16.
//  Copyright © 2016 Orchard. All rights reserved.
//


struct SKConstants{

    /* USER DEFAULT KEYS */
    static let UDK_For_CloudKit_Changes_Notifications: String       = "CLOUDKIT_CHANGES_NOTIFICATIONS_SET"
    static let UDK_For_CloudKit_Last_Known_Beacon_Minor: String     = "CLOUDKIT_CURRENT_BEACON_MINOR"
    static let UDK_For_CloudKit_Last_Room_Data_ID: String           = "CLOUDKIT_LAST_ROOM_DATA_ENTRY_ID"
    static let UDK_For_CloudKit_Last_Step_Count_Day: String         = "CLOUDKIT_LAST_STEP_COUNT_DAY"
    static let UDK_For_CloudKit_Last_Blood_Pressure_Day: String     = "CLOUDKIT_LAST_BLOOD_PRESSURE_DAY"
    static let UDK_For_Step_Count_Critical_Level: String            = "CRITICAL_STEP_COUNT"
    static let UDK_For_Blood_Pressure_Critical_Level: String        = "CRITICAL_BLOOD_PRESSURE"
    
    /* STRINGS */
    static let ICloud_Table_Name_For_Room_Data                      = "RoomData"
    static let ICloud_Table_Name_For_Triggers                       = "Triggers"
    static let ICloud_Table_Name_For_Encouragements                 = "Encouragements"
    static let ICloud_Table_Name_For_StepsCount                     = "StepsCount"
    static let ICloud_Table_Name_For_BloodPressure                  = "BloodPressure"
    
    #if PATIENTAPP
        static let ICloud_Container_Name_For_App                        = "iCloud.com.orchrd.Dissertation"
    #endif
    
    #if CARETAKERAPP
        static let ICloud_Container_Name_For_App                        = "iCloud.com.orchrd.Dissertation"
    #endif
    
    
    //MARK:- Constants returning functions
    
    static func getCriticalStepsCount() -> Int{
        var criticalStepsCount = NSUserDefaults.standardUserDefaults().integerForKey(SKConstants.UDK_For_Step_Count_Critical_Level)
        if criticalStepsCount <= 0 {
            criticalStepsCount = 2000
            NSUserDefaults.standardUserDefaults().setInteger(2000, forKey: SKConstants.UDK_For_Step_Count_Critical_Level)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return criticalStepsCount
    }
    
    static func getCriticalBloodPressure() -> Int{
        var criticalBloodPressure = NSUserDefaults.standardUserDefaults().integerForKey(SKConstants.UDK_For_Blood_Pressure_Critical_Level)
        if criticalBloodPressure <= 0 {
            criticalBloodPressure   = 50
            NSUserDefaults.standardUserDefaults().setInteger(50, forKey: SKConstants.UDK_For_Blood_Pressure_Critical_Level)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        return criticalBloodPressure
    }
    
}
