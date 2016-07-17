//
//  Constants.h
//  DissertationM8K
//
//  Created by Shayan K. on 7/17/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefinitionsConversion : NSObject

+ (NSUUID *) getProximityUUID;
+ (NSUUID *) getMacBeaconProximityUUID;
+ (NSUUID *) getiOSBeaconProximityUUID;

@end
