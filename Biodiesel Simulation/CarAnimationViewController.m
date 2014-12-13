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

@property(strong, nonatomic) AVAudioPlayer *highScoreSound;

@end

@implementation CarAnimationViewController

- (AVAudioPlayer*)highScoreSound
{
    if(!_highScoreSound)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Level Up Sound" ofType:@"mp3"]];
        _highScoreSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [_highScoreSound prepareToPlay];
    }
    return _highScoreSound;
}

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
    if([CarDistanceGame checkDistanceForLevelUp:[self.gameResults[@"Distance"] floatValue]])
    {
        int currentLevel = [CarDistanceGame getHighestUnlockedLevel];
        
        UIAlertController *levelUpAlert =
        [UIAlertController alertControllerWithTitle:@"Congrats!"
                                            message: [NSString stringWithFormat:@"You leveled up to level %i!", currentLevel]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ [self displayGameResults]; }];
        
        [levelUpAlert addAction: okAction];
        
        [self presentViewController:levelUpAlert animated:YES completion:nil];
        [self.highScoreSound play];
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
