//
//  SKDBManager.swift
//  DissertationM8K
//
//  Created by Shayan K. on 7/25/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

import UIKit

class SKDBManager: NSObject {
    
    var dynamoDBManager: AWSDynamoDBObjectMapper;
    
    // initialize and connect to the online database at Amazon Web Services
    override init(){
        dynamoDBManager = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper();
        super.init();
    }
    
    // Scans all values from the online database
    func scanAllValues(){
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 20
        
        dynamoDBManager.scan( SKTrigger.self, expression:  scanExpression).continueWithSuccessBlock { (task: AWSTask) -> AnyObject? in
            
            if((task.result) != nil){
                let pagingOutput : AWSDynamoDBPaginatedOutput = task.result as! AWSDynamoDBPaginatedOutput;
                for item in pagingOutput.items{
                    let trigger = item as! SKTrigger;
                    print("Name: " + trigger.name);
                }
            }
            
            return nil;
        }
        
    }

}
