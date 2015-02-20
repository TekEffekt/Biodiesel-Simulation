//
//  InputDataTableViewController.h
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 10/19/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GAITrackedViewController.h"

@interface InputDataTableViewController : UITableViewController

@property(strong, nonatomic) NSDictionary *previousSimulationInputs;

@end
