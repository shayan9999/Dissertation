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

    
    /* STRINGS */
    static let ICloud_Table_Name_For_Room_Data                      = "RoomData"
    static let ICloud_Table_Name_For_Triggers                       = "Triggers"
    static let ICloud_Table_Name_For_StepsCount                     = "StepsCount"
    
    #if PATIENTAPP
        static let ICloud_Container_Name_For_App                        = "iCloud.com.orchrd.Dissertation"
    #endif
    
    #if CARETAKERAPP
        static let ICloud_Container_Name_For_App                        = "iCloud.com.orchrd.Dissertation"
    #endif
    
}
