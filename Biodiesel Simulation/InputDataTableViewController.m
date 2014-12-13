//
//  InputDataTableViewController.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 10/19/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "InputDataTableViewController.h"
#import "SimulationViewController.h"
#import "SmartSlider.h"
#import "CarDistanceGame.h"
#import "PageContentViewController.h"

@interface InputDataTableViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIImageView *litIcon;

@property (weak, nonatomic) IBOutlet UIImageView *smallDroplet;
@property (weak, nonatomic) IBOutlet UIImageView *bigDroplet;
@property (weak, nonatomic) IBOutlet UIImageView *smallDroplet2;
@property (weak, nonatomic) IBOutlet UIImageView *bigDroplet2;
@property (weak, nonatomic) IBOutlet UIImageView *smallTime;
@property (weak, nonatomic) IBOutlet UIImageView *bigTime;
@property (weak, nonatomic) IBOutlet UIImageView *smallTime2;
@property (weak, nonatomic) IBOutlet UIImageView *bigTime2;
@property (weak, nonatomic) IBOutlet UIImageView *smallThermometer;
@property (weak, nonatomic) IBOutlet UIImageView *bigThermometer;

@property (weak, nonatomic) IBOutlet UIImageView *smallOil;
@property (weak, nonatomic) IBOutlet UIImageView *mediumOil;
@property (weak, nonatomic) IBOutlet UIImageView *bigOil;

@property (weak, nonatomic) IBOutlet SmartSlider *methanolSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *catalystSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *settlingTimeSlider;
@property (weak, nonatomic) IBOutlet SmartSlider *mixingLengthSlider;

@property (weak, nonatomic) IBOutlet UIButton *startSimulationButton;

@property(nonatomic) BOOL justLoaded;

// oil value stored in a property due to not being stored in a slider
@property(nonatomic) CGFloat oil;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property(strong, nonatomic) UIView *blurView;

@property(nonatomic) BOOL tutorialOn;

@end

@implementation InputDataTableViewController

#pragma mark - User Interface

- (IBAction)sliderTouched:(UIPanGestureRecognizer *)sender
{
    BOOL slidingLeft = YES;
    BOOL slidingRight = NO;
    SmartSlider *slider = (SmartSlider*)sender.view;
    
    if(slider.value < slider.previousValue)
    {
        slidingLeft = YES;
        slidingRight = NO;
    } else if(slider.value > slider.previousValue)
    {
        slidingRight = YES;
        slidingLeft = NO;
    } else
    {
        slidingRight = NO;
        slidingLeft = NO;
    }
    
    slider.previousValue = slider.value;
    
    self.litIcon.tintColor = [UIColor blackColor];
    
    if(sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged)
    {
        if(slider == self.methanolSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallDroplet;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigDroplet;
            }
        } else if(slider == self.catalystSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallDroplet2;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigDroplet2;
            }
        } else if(slider == self.temperatureSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallThermometer;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigThermometer;
            }
        } else if(slider == self.settlingTimeSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallTime;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigTime;
            }

        } else if(slider == self.mixingLengthSlider)
        {
            if(slidingLeft)
            {
                self.litIcon = self.smallTime2;
                
            } else if(slidingRight)
            {
                self.litIcon = self.bigTime2;
            }

        }
        self.litIcon.image = [self.litIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.litIcon setTintColor:self.view.tintColor];
    } else if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.litIcon.tintColor = [UIColor blackColor];
        self.litIcon = nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (section == 0){
        header = [NSString stringWithFormat:@"INITIAL METHANOL: %i MOLES", (int)self.methanolSlider.value];
    } else if(section == 1)
    {
        header = [NSString stringWithFormat:@"INITIAL CATALYST: %i MOLES", (int)self.catalystSlider.value];
    } else if(section == 2)
    {
        header = [NSString stringWithFormat:@"INITIAL TEMPERATURE: %i ˚C", (int)self.temperatureSlider.value];
    } else if(section == 3)
    {
        header = [NSString stringWithFormat:@"MIXING LENGTH: %i MINUTES", (int)self.settlingTimeSlider.value];
    } else if(section == 4)
    {
        header = [NSString stringWithFormat:@"SETTLING TIME: %i MINUTES", (int)self.mixingLengthSlider.value];
    } else if(section == 5 && !self.justLoaded)
    {
        header = [NSString stringWithFormat:@"INITIAL OIL: %i MOLES", (int)self.oil];
    } else if(section == 5 && self.justLoaded)
    {
        header = @"INITIAL OIL: ??? MOLES";
    }
    
    return header;
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    if(sender == self.methanolSlider)
    {
        [self.tableView headerViewForSection:0].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:0];
    } else if(sender == self.catalystSlider)
    {
        [self.tableView headerViewForSection:1].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:1];
    } else if(sender == self.temperatureSlider)
    {
        [self.tableView headerViewForSection:2].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:2];
    } else if(sender == self.settlingTimeSlider)
    {
        [self.tableView headerViewForSection:3].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:3];
    } else if(sender == self.mixingLengthSlider)
    {
        [self.tableView headerViewForSection:4].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:4];
    }
}

- (IBAction)oilButtonPressed:(UITapGestureRecognizer *)sender
{
    [self enableAppropriateOilButtons];
    
    self.justLoaded = NO;
    
    if(sender.view == self.smallOil)
    {
        self.oil = 5;
        self.smallOil.tintColor = self.view.tintColor;
    } else if(sender.view == self.mediumOil)
    {
        self.oil = 10;
        self.mediumOil.tintColor = self.view.tintColor;
    } else if(sender.view == self.bigOil)
    {
        self.oil = 15;
        self.bigOil.tintColor = self.view.tintColor;
    }
    
    [self.tableView headerViewForSection:5].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:5];
}


- (void)enableAppropriateOilButtons
{
    int highestUnlockedLevel = [CarDistanceGame getHighestUnlockedLevel];
       
    self.bigOil.image = [self.bigOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.bigOil setTintColor:[UIColor lightGrayColor]];
    self.mediumOil.image = [self.mediumOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.mediumOil setTintColor:[UIColor lightGrayColor]];
    self.smallOil.image = [self.smallOil.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.smallOil setTintColor:[UIColor lightGrayColor]];
    
    self.bigOil.userInteractionEnabled = NO;
    self.mediumOil.userInteractionEnabled = NO;
    self.smallOil.userInteractionEnabled = NO;
    
    if(highestUnlockedLevel >= 3)
    {
        self.bigOil.tintColor = [UIColor blackColor];
        self.bigOil.userInteractionEnabled = YES;
    }
    
    if(highestUnlockedLevel >= 2)
    {
        self.mediumOil.tintColor = [UIColor blackColor];
        self.mediumOil.userInteractionEnabled = YES;
    }
    
    if(highestUnlockedLevel >= 1)
    {
        self.smallOil.tintColor = [UIColor blackColor];
        self.smallOil.userInteractionEnabled = YES;
    }
}

# pragma mark - MVC Lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView headerViewForSection:0].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:1].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:2].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:3].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:4].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    [self.tableView headerViewForSection:5].textLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:12];
    
    [self enableAppropriateOilButtons];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Faded In"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.oil = 5;
    self.justLoaded = YES;
}

#pragma mark - Tutorial

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 7)
    {
        if(indexPath.row == 0)
        {
            [self loadTutorial];
        }
    }
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)loadTutorial
{
    self.navigationItem.rightBarButtonItem.title = @"EXIT";
    self.tutorialOn = YES;
    self.navigationItem.hidesBackButton = YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    blurEffectView.alpha = 0.0;
    
    self.blurView = blurEffectView;
        
    [self.view addSubview:blurEffectView];
    
    [UIView animateWithDuration:1.5 animations:^{
        blurEffectView.alpha = 1;
    } completion:^(BOOL finished) {
        self.pageTitles = @[@"Welcome to Biodiesel Simulator! We have prepared a quick and handy tutorial to get you started. Swipe through to read!",
                            @"Biodiesel is a domestically produced, renewable fuel that can be manufactured from organic materials like cooking oil or animal fats. ",
                            @"Blah blah blah explanation explanation explanation explanation explanation....", @"TEST"];
        self.pageImages = @[@"page1.jpg", @"page2.jpeg", @"page3.jpg", @"page4.png"];
        
        // Create page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        
        PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        // Change the size of page view controller
        self.pageViewController.view.frame = CGRectMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y, self.tableView.contentOffset.x + self.tableView.bounds.size.width, self.tableView.contentOffset.y + self.tableView.bounds.size.height);
        
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        self.tableView.scrollEnabled = NO;
    }];
}

#pragma mark - Data

- (NSDictionary*)gatherDataForSimulation
{
    NSDictionary *sliderValues = @{
                                   @"Initial Oil":[NSNumber numberWithFloat:self.oil],
                                         @"Initial Methanol":[NSNumber numberWithFloat:self.methanolSlider.value],
                                         @"Initial Catalyst":[NSNumber numberWithFloat:self.catalystSlider.value],
                                         @"Temperature":[NSNumber numberWithFloat:self.temperatureSlider.value],
                                         @"Settling Time":[NSNumber numberWithFloat:self.settlingTimeSlider.value],
                                         @"Mixing Length":[NSNumber numberWithFloat:self.mixingLengthSlider.value]};
    NSLog(@"%@", sliderValues);
    return sliderValues;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"To Simulation"])
       {
           SimulationViewController *simulationViewController = segue.destinationViewController;
           simulationViewController.simulationData = [self gatherDataForSimulation];
       }
}
- (IBAction)remove:(UIBarButtonItem *)sender
{
    if(self.tutorialOn)
    {
        [self.blurView removeFromSuperview];
        [self.pageViewController.view removeFromSuperview];
        self.tableView.scrollEnabled = YES;
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Faded In"];
        
        self.tutorialOn = NO;
        self.navigationItem.rightBarButtonItem.title = @"Auto";
        self.navigationItem.hidesBackButton = NO;

    }
}

@end