//
//  SKRoomData.swift
//  DissertationM8K
//
//  Created by Shayan K. on 8/16/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import Foundation

class SKRoomData : NSObject {
    var name : String?
    var start_time : NSDate?
    var end_time : NSDate?
    
    static func tableKeyForName()-> String{return "name"}
    static func tableKeyForStartTime()-> String{return "start_time"}
    static func tableKeyForEndTime()-> String{return "end_time"}
}