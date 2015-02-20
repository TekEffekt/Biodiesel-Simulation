//
//  CarAnimationViewController.h
//  Biodiesel Simulation
//
//  Created by App Factory on 11/14/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"
#import "GAITrackedViewController.h"

@interface CarAnimationViewController : GAITrackedViewController<CustomIOS7AlertViewDelegate>

@property(strong, nonatomic) NSDictionary *gameResults;
@property(strong, nonatomic) NSDictionary *simulationResults;
@property(strong, nonatomic) NSDictionary *simulationData;

@end
