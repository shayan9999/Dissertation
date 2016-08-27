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
}



