//
//  SKEncouragement.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/11/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation

class SKEncouragement: NSObject{
    var name: String?
    var time: NSDate?
    
    static func tableKeyForName()-> String {return "name"}
    static func tableKeyForTime()-> String {return "timing"}
}
