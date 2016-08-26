//
//  SKStepsCount.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/23/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation

class SKStepsCount: NSObject{
    var total: NSInteger?
    var day: NSDate?
    
    static func tableKeyForTotal()-> String{return "total"}
    static func tableKeyForDay()-> String{return "date"}
}