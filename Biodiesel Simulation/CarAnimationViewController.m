//
//  CarAnimationViewController.m
//  Biodiesel Simulation
//
//  Created by App Factory on 11/14/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "CarAnimationViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "CarAnimationScene.h"
#import "CarDistanceGame.h"
#import "ResultsTableViewController.h"

@interface CarAnimationViewController () <CarAnimationController>

@end

@implementation CarAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SKView *skView = (SKView*)self.view;
    CarAnimationScene *scene = [[CarAnimationScene alloc] initWithSize:skView.bounds.size];
    scene.gameResults = self.gameResults;
    scene.delegate = self;
    
    [skView presentScene:scene];
}

- (void)animationFinished:(CarAnimationScene*)scene
{
    if([CarDistanceGame checkDistanceForLevelUp:[self.gameResults[@"Distance"] floatValue] andStoreLevelUpInfo:YES])
    {
        int currentLevel = [CarDistanceGame getHighestUnlockedLevel];
        
        UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 160)];
        
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 270, 150)];
        background.center = outerView.center;
        background.image = [UIImage imageNamed:@"flowerBackground2"];
        
        UILabel *levelUpLabel = [[UILabel alloc] init];
        levelUpLabel.text = [NSString stringWithFormat:@"You leveled up to level %i!", currentLevel];
        levelUpLabel.frame = CGRectMake(0, 0, 250, 150);
        levelUpLabel.center = background.center;
        //levelUpLabel.textColor = [UIColor whiteColor];
        levelUpLabel.textAlignment = NSTextAlignmentCenter;
        levelUpLabel.backgroundColor = [UIColor clearColor];
        levelUpLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
        
        [background addSubview:levelUpLabel];
        [outerView addSubview:background];
        
        CustomIOS7AlertView *levelUpAlert = [[CustomIOS7AlertView alloc] init];
        
        [levelUpAlert setContainerView:outerView];
        [levelUpAlert setButtonTitles:@[@"Next"]];
        
        [levelUpAlert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            [self displayGameResults];
        }];
        
        [levelUpAlert show];
        
    } else
    {
        [self displayGameResults];
    }
}

- (void)displayGameResults
{
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *price =  [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[self.gameResults[@"Price"] floatValue]]];
    
    UIAlertController *resultAlert =
    [UIAlertController alertControllerWithTitle:@"Results"
                                        message: [NSString stringWithFormat:@"You travelled %i miles for %@ a gallon!",
                                                  [self.gameResults[@"Distance"] integerValue], price]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ [self performSegueWithIdentifier:@"To Results" sender:self]; }];
    
    [resultAlert addAction:okAction];
    
    [self presentViewController:resultAlert animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"To Results"])
    {
        ResultsTableViewController *destination = (ResultsTableViewController*)segue.destinationViewController;
        destination.gameResults = self.gameResults;
        destination.simulationResults = self.simulationResults;
        destination.simulationData = self.simulationData;
    
        destination.navigationItem.hidesBackButton = YES;
        self.navigationController.navigationBarHidden = NO;
    }
}

@end
