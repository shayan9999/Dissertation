//
//  Enums.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/11/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import HealthKit


enum HealthDataCategory: Int {
    case StepsCount = 1, FallCount, HeartRate, BloodPressure, Sleep 
}
enum HealthDataTriggerRelation: Int {
    case GreaterThan = 1, LessThan, EqualTo
}

enum HealthDataTriggerDuration: Int {
    case PerDay = 1, PerWeek, PerMonth
}

enum EncouragementDataTiming: Int{
    case EveryDay = 1, OnWeekends, OnWeekdays, EveryWeek, EveryMonth
}



