//
//  CarDistanceGame.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/3/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "CarDistanceGame.h"

@implementation CarDistanceGame

#define LEVEL_TWO_DISTANCE 90
#define LEVEL_THREE_DISTANCE 223

+ (NSDictionary*)computeTheDistanceWithFuel:(NSDictionary *)fuel
{
    double wallet = 50; // the amount of money available to buy fuel
    double pricePerGallon = [(NSNumber*)fuel[@"Cost"] doubleValue];
    double effeciency = [(NSNumber*)fuel[@"Eout"] doubleValue] / 10;
#warning Smoking with below 95% conversion
    
    double gallons = wallet / pricePerGallon;
    
    double distanceTravelled = gallons * effeciency;
    
    NSDictionary *gameResults = @{@"Price": [NSNumber numberWithDouble:pricePerGallon], @"Gallons": [NSNumber numberWithDouble:gallons],
                                  @"Distance": [NSNumber numberWithDouble:distanceTravelled]};
    
    return gameResults;
}

+ (int)getHighestUnlockedLevel
{
    int highestUnlockedLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"Highest Unlocked Level"];
    
    if(!highestUnlockedLevel)
    {
        highestUnlockedLevel = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:highestUnlockedLevel forKey:@"Highest Unlocked Level"];
    }
    
    return highestUnlockedLevel;
}

+ (BOOL)checkDistanceForLevelUp:(CGFloat)distance
{
    BOOL shouldLevelUp = NO;
    int currentLevel = 1;
    
    if(distance > LEVEL_THREE_DISTANCE)
    {
        currentLevel = 3;
    } else if(distance > LEVEL_TWO_DISTANCE)
    {
        currentLevel = 2;
    }
    
    if([self getHighestUnlockedLevel] < currentLevel)
    {
        shouldLevelUp = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:currentLevel forKey:@"Highest Unlocked Level"];
    
    return shouldLevelUp;
}

@end