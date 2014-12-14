//
//  ResultsTableViewController.m
//  Biodiesel Simulation
//
//  Created by App Factory on 11/18/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "CarDistanceGame.h"

@interface ResultsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *gallonsLabel;

@property (weak, nonatomic) IBOutlet UILabel *ethanolLabel;
@property (weak, nonatomic) IBOutlet UILabel *conversionLabel;

@property (weak, nonatomic) IBOutlet UILabel *methanolLabel;
@property (weak, nonatomic) IBOutlet UILabel *catalystLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *mixingLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *settlingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *oilLabel;
@end

@implementation ResultsTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    int currentLevel = [CarDistanceGame getHighestUnlockedLevel];
    NSString *level;
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *price =  [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[self.gameResults[@"Price"] floatValue]]];

    
    switch(currentLevel)
    {
        case 1: level = @"One"; break;
        case 2: level = @"Two"; break;
        case 3: level = @"Three"; break;
    }
    
    self.levelLabel.text = level;
    self.levelLabel.textColor = [UIColor orangeColor];
    self.distanceLabel.text = [NSString stringWithFormat:@"%i miles", [self.gameResults[@"Distance"] intValue]];
    self.costLabel.text = price;
    self.gallonsLabel.text = [NSString stringWithFormat:@"%i gallons", [self.gameResults[@"Gallons"] intValue]];
    
    self.ethanolLabel.text = [NSString stringWithFormat:@"%i moles", [self.simulationResults[@"Eout"] integerValue]];
    self.conversionLabel.text = [NSString stringWithFormat:@"%i%%", [self.simulationResults[@"Convout"] intValue]];
    
    self.methanolLabel.text = [NSString stringWithFormat:@"%i moles", [self.simulationData[@"Initial Methanol"] integerValue]];
    self.catalystLabel.text = [NSString stringWithFormat:@"%i moles", [self.simulationData[@"Initial Catalyst"] integerValue]];
    self.temperatureLabel.text = [NSString stringWithFormat:@"%i ˚C", [self.simulationData[@"Temperature"] integerValue]];
    self.mixingLengthLabel.text = [NSString stringWithFormat:@"%i minutes", [self.simulationData[@"Mixing Length"] integerValue]];
    self.settlingTimeLabel.text = [NSString stringWithFormat:@"%i minutes", [self.simulationData[@"Settling Time"] integerValue]];
    self.oilLabel.text = [NSString stringWithFormat:@"%i moles", [self.simulationData[@"Initial Oil"] integerValue]];
}

@end
