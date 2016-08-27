//
//  SKTriggers.swift
//  DissertationM8K
//
//  Created by Shayan K. on 7/25/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import UIKit

class SKTrigger{
    
    var name: String?;
    var id: NSInteger?;
    var relation: SKHealthDataTriggerRelation?;
    var category: SKHealthDataCategory?;
    var duration: SKHealthDataTriggerDuration?;
    var constant: Double?;
    
    static func tableKeyForName()-> String {return "description"}
    static func tableKeyForCategory()-> String {return "category"}
    static func tableKeyForConstant()-> String {return "constant"}
    static func tableKeyForDuration()-> String {return "duration"}
    static func tableKeyForRelation()-> String {return "relation"}
}
