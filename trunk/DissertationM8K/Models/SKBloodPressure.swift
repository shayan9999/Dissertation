//
//  SKBloodPressure.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/31/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation

class SKBloodPressure: NSObject{
    var total: NSInteger?
    var day: NSDate?
    
    static func tableKeyForTotal()-> String{return "total"}
    static func tableKeyForDay()-> String{return "date"}
}