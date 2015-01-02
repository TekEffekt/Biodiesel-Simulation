//
//  ResultsTableViewController.m
//  Biodiesel Simulation
//
//  Created by App Factory on 11/18/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "CarDistanceGame.h"
#import "InputDataTableViewController.h"
#import "WYPopoverController.h"

#import "ItemDefinitionViewController.h"

@interface ResultsTableViewController () <WYPopoverControllerDelegate>
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

@property(strong, nonatomic) WYPopoverController *popover;

@property(strong, nonatomic) NSArray *definitions;

@property(strong, nonatomic) UIViewController *controller;
@property(strong, nonatomic) UITextView *textView;

@end

@implementation ResultsTableViewController

- (NSArray*)definitions
{
    if(!_definitions)
    {
        NSArray *firstSection =
  @[@"Your current level. You get to higher levels by making the car travel certain distances. For example, you only have to travel 95 miles to unlock level 3!",
    @"The number of gallons that were bought. Only $50 worth of your fuel is bought to fill up the car. So, keep your fuel cheap if you want to buy more gallons.",
    @"The cost of one gallon of your fuel. The price is determined by the temperature that your fuel is cooked in, the mixing length that you have to cook it for, and the oil and methanol that is put in.",
    @"The distance in miles that your car travelled. The number of miles is determined by how much ethanol is in each gallon, and how many gallons that were bought with $50."];
        
        NSArray *secondSection = @[@"The amount of ethanol produced per gallon of fuel.",
                                   @"The conversion ratio a.k.a quality of your fuel. This number determines the percentage of your fuel that is biodiesel and not waste. Remember, the conversion ratio has to be above 95% to have the car even start!"];
        
        NSArray *thirdSection = @[@"The methanol input. It costs money, so be mindful of how much you put in.",
                                  @"The catalyst input. It has little effect.",
                                  @"The temperature that your fuel will be cooked at. This, along with the mixing length affects price. For example, cooking fuel at a lower temperature for 10 minutes will likely cost less than cooking fuel at a much higher temperature for 9 minutes.",
                                  @"The amount of time that you cook the fuel.",
                                  @"The amount of time that you let the fuel settle after cooking.",
                                  @"The oil that you put in your fuel. This determines the cost of the fuel, and also heavily dertermines how much ethanol is produced in the simulation. More oil almost always means that the car can travel farther, so the oil is locked away at set levels to avoid making the game too easy!"];
        
        _definitions = @[firstSection, secondSection, thirdSection];
    }
    
    return _definitions;
}

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
        default: level = @"One"; break;
    }
    
    self.levelLabel.text = level;
    self.levelLabel.textColor = [UIColor orangeColor];
    self.distanceLabel.text = [NSString stringWithFormat:@"%i miles", [self.gameResults[@"Distance"] intValue]];
    self.costLabel.text = price;
    self.gallonsLabel.text = [NSString stringWithFormat:@"%i gallons", [self.gameResults[@"Gallons"] intValue]];
    
    self.ethanolLabel.text = [NSString stringWithFormat:@"%i moles", (int)[self.simulationResults[@"Eout"] integerValue]];
    self.conversionLabel.text = [NSString stringWithFormat:@"%i%%", [self.simulationResults[@"Convout"] intValue]];
    
    self.methanolLabel.text = [NSString stringWithFormat:@"%i moles", (int)[self.simulationData[@"Initial Methanol"] integerValue]];
    self.catalystLabel.text = [NSString stringWithFormat:@"%i moles", (int)[self.simulationData[@"Initial Catalyst"] integerValue]];
    self.temperatureLabel.text = [NSString stringWithFormat:@"%i ˚C", (int)[self.simulationData[@"Temperature"] integerValue]];
    self.mixingLengthLabel.text = [NSString stringWithFormat:@"%i minutes", (int)[self.simulationData[@"Mixing Length"] integerValue]];
    self.settlingTimeLabel.text = [NSString stringWithFormat:@"%i minutes", (int)[self.simulationData[@"Settling Time"] integerValue]];
    self.oilLabel.text = [NSString stringWithFormat:@"%i moles", (int)[self.simulationData[@"Initial Oil"] integerValue]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    int rowNumber = (int)indexPath.row;
    int sectionNumber = (int)indexPath.section;
    
    [self displayDefinitionInRowNumber:rowNumber andsectionNumber:sectionNumber andInView:cell.viewForBaselineLayout];
}

- (void)displayDefinitionInRowNumber:(int)rowNumber andsectionNumber:(int)sectionNumber andInView:(UIView*)view
{
    if(!self.controller)
    {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
        self.textView.text = self.definitions[sectionNumber][rowNumber];
        self.textView.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:15];
        
        CGFloat newHeight = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)].height;
        self.textView.frame = CGRectMake(0, 0, 300, newHeight);
        
        self.textView.userInteractionEnabled = NO;
        
        self.controller = [[UIViewController alloc] init];
        self.controller.view = [[UIView alloc] initWithFrame:self.textView.frame];
        self.textView.center = self.controller.view.center;
        
        [self.controller.view addSubview:self.textView];
        
        self.popover = [[WYPopoverController alloc] initWithContentViewController:self.controller];
        self.popover.delegate = self;
        self.popover.popoverContentSize = self.controller.view.frame.size;
        
        [self.popover presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Back To Input"])
    {
        InputDataTableViewController *controller = (InputDataTableViewController*)segue.destinationViewController;
        
        controller.previousSimulationInputs = self.simulationData;
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    self.popover.delegate = nil;
    self.popover = nil;
    self.controller = nil;
    self.textView = nil;
}

@end
