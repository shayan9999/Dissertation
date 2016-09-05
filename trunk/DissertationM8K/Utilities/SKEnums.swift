//
//  Enums.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/11/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import HealthKit


enum SKHealthDataCategory: Int {
    case StepsCount = 1, FallCount, HeartRate, BloodPressure, Sleep 
}
enum SKHealthDataTriggerRelation: Int {
    case GreaterThan = 1, LessThan, EqualTo
}

enum SKHealthDataTriggerDuration: Int {
    case PerDay = 1, PerWeek, PerMonth
}

enum SKEncouragementDataTiming: Int{
    case Once = 1, EveryDay, OnWeekdays, EveryWeek, EveryMonth
    
    var timingPrefix : String {
        switch self {
        // Use Internationalization, as appropriate.
            case .Once: return "Once on ";
            case .EveryDay: return "Every day at ";
            case .OnWeekdays: return "Weekdays at ";
            case .EveryWeek: return "Every Week starting ";
            case .EveryMonth: return "Every Month starting ";
        }
    }
    
    func hasAssociatedDay()->Bool{
        if self == .Once || self == .EveryWeek || self == .EveryMonth {
            return true;
        }
        return false
    }
}



