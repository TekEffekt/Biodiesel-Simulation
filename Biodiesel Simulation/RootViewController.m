//
//  RootViewController.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 10/12/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)unwind:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    if(self.navigationController)
    {
        NSLog(@"Exits");
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
