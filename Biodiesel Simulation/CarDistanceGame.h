//
//  CarDistanceGame.h
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/3/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CarDistanceGame : NSObject

+ (NSDictionary*)computeTheDistanceWithFuel:(NSDictionary*)fuel;
+ (int)getHighestUnlockedLevel;
+ (BOOL)checkDistanceForLevelUp:(CGFloat)distance;

@end
