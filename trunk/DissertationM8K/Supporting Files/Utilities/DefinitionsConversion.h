//
//  Constants.h
//  DissertationM8K
//
//  Created by Shayan K. on 7/17/16.
//  Copyright © 2016 Orchard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ORCHARD_LIST_DEVICE_COLORS @"Black", @"Space Grey", @"Silver", @"Gold", @"Green", @"Blue", @"Yellow", @"Red", @"White", @"Rose Gold", @"Pink"

#define COLOR_BLACK_FOR_TEXTS  [UIColor colorWithRed: 151.0/255.0 green: 160.0/255.0 blue: 160.0/255.0 alpha:1.0]
#define COLOR_BLUE_FOR_TEXTS   [UIColor colorWithRed: 1.0/255.0 green: 135.0/255.0 blue: 167.0/255.0 alpha:1.0]
#define COLOR_RED_FOR_TEXTS    [UIColor colorWithRed: 151.0/255.0 green: 160.0/255.0 blue: 160.0/255.0 alpha:1.0]
#define COLOR_YELLOW_FOR_TEXTS [UIColor colorWithRed: 255.0/255.0 green: 241.0/255.0 blue: 0/255.0 alpha:1.0]

@interface DefinitionsConversion : NSObject

+ (NSUUID *) getProximityUUID;
+ (NSUUID *) getMacBeaconProximityUUID;
+ (NSUUID *) getiOSBeaconProximityUUID;

+ (UIColor *) getBlackColorForTexts;
+ (UIColor *) getBlueColorForTexts;
+ (UIColor *) getRedColorForTexts;
+ (UIColor *) getYellowColorForTexts;

@end
