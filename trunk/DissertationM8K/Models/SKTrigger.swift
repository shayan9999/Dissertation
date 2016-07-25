//
//  SKTriggers.swift
//  DissertationM8K
//
//  Created by Shayan K. on 7/25/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import UIKit

class SKTrigger: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var name: String!;
    var id: NSInteger!;
    var parameter: NSInteger!;
    var category: NSInteger!;
    var value: NSInteger!;
    
    static func dynamoDBTableName() -> String {
        return "triggers";
    }
    
    static func hashKeyAttribute() -> String {
        return "HASH";
    }

}
