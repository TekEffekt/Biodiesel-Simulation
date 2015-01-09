//
//  Reachability.h
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 1/8/15.
//  Copyright (c) 2015 University Of Wisconsin Parkside. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Reachability : NSObject

+ (BOOL)connectedToInternet;
+ (UIAlertController*)noInternetAlert;

@end
