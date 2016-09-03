//
//  SKSettings.swift
//  DissertationM8K
//
//  Created by Shayan K. on 9/1/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation

class SKSettings: NSObject{
    var caretakerContact        : String?
    var criticalBloodPressure   : NSInteger?
    var criticalStepsCount      : NSInteger?
    
    static func tableKeyForCaretakerContact()-> String{return "caretaker_contact"}
    static func tableKeyForCriticalStepsCount()-> String{return "critical_step_count"}
    static func tableKeyForCriticalBloodPressure()-> String{return "critical_bp"}
}