//
//  ResultsTableViewController.h
//  Biodiesel Simulation
//
//  Created by App Factory on 11/18/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsTableViewController : UITableViewController

@property(strong, nonatomic) NSDictionary *gameResults;
@property(strong, nonatomic) NSDictionary *simulationResults;
@property(strong, nonatomic) NSDictionary *simulationData;

@end
