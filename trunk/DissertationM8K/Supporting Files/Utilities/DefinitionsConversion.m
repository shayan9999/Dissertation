//
//  Constants.m
//  DissertationM8K
//
//  Created by Shayan K. on 7/17/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

#import "DefinitionsConversion.h"
#import <EstimoteSDK/ESTBeaconDefinitions.h>

@implementation DefinitionsConversion

+ (NSUUID *) getProximityUUID{
    return ESTIMOTE_PROXIMITY_UUID;
}

+ (NSUUID *) getMacBeaconProximityUUID{
    return ESTIMOTE_MACBEACON_PROXIMITY_UUID;
}

+ (NSUUID *) getiOSBeaconProximityUUID{
    return ESTIMOTE_IOSBEACON_PROXIMITY_UUID;
}


+ (UIColor *) getBlackColorForTexts{
    return COLOR_BLACK_FOR_TEXTS;
}

+ (UIColor *) getBlueColorForTexts{
    return COLOR_BLUE_FOR_TEXTS;
}

+ (UIColor *) getRedColorForTexts{
    return COLOR_RED_FOR_TEXTS;
}

+ (UIColor *) getYellowColorForTexts{
    return COLOR_YELLOW_FOR_TEXTS;
}

@end
