//
//  SimulationViewController.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 10/22/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "SimulationViewController.h"
#import "TheSimulation.h"
#import "SimulationOperation.h"
#import "CarDistanceGame.h"
#import "CarAnimationViewController.h"
#import "UIView+Glow.h"

@interface SimulationViewController () <SimulationController>

@property(nonatomic, strong) NSOperationQueue *simulationQueue;
@property(nonatomic, strong) SimulationOperation *simulationOperation;

@property(nonatomic) float initialOil;
@property(nonatomic) float initialMethanol;
@property(nonatomic) float initialCatalyst;
@property(nonatomic) float temperature;
@property(nonatomic) float settlingTime;
@property(nonatomic) float mixingLength;

@property(strong, nonatomic) NSDictionary *simulationResults;
@property(strong, nonatomic) NSDictionary *gameResults;

@property (weak, nonatomic) IBOutlet UIImageView *vialImage;

@end

@implementation SimulationViewController

#pragma mark - Setters and Getters
- (NSOperationQueue*)simulationQueue
{
    if(!_simulationQueue)_simulationQueue = [[NSOperationQueue alloc] init];
    _simulationQueue.name = @"Simulation Queue";
    return _simulationQueue;
}

#pragma mark - View Controller Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set the initial data for the simulation
    self.initialOil = [[self.simulationData objectForKey:@"Initial Oil"] floatValue];
    self.initialMethanol = [[self.simulationData objectForKey:@"Initial Methanol"] floatValue];
    self.initialCatalyst = [[self.simulationData objectForKey:@"Initial Catalyst"] floatValue];
    self.temperature = [[self.simulationData objectForKey:@"Temperature"] floatValue];
    self.settlingTime = [[self.simulationData objectForKey:@"Settling Time"] floatValue];
    self.mixingLength = [[self.simulationData objectForKey:@"Mixing Length"] floatValue];
    
    [self startSimulation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.simulationOperation cancel];
}

- (void)viewDidLayoutSubviews
{
    [self addActivityHUD];
}

#pragma mark - Simulation Code

// Start the simulation by initializing a simulation operation and adding it to the simulation queue
- (void)startSimulation
{
    self.simulationOperation = [[SimulationOperation alloc] initSimulationWith:self.initialOil methanol:self.initialMethanol catalyst:self.initialMethanol temperature:self.temperature mixingLength:self.mixingLength andSettlingTime:self.settlingTime];
    self.simulationOperation.delegate = self;
    [self.simulationQueue addOperation:self.simulationOperation];
}

// The simulation operation will call this method and pass itself as an argument.
// Then, this method will grab the simulation results and update the UI.
- (void)simulationFinsihed:(SimulationOperation*)operation
{
    self.simulationResults = operation.results;
    NSLog(@"The Results: %@", self.simulationResults);
    self.gameResults = [CarDistanceGame computeTheDistanceWithFuel:self.simulationResults];
    
    [self uploadResults];
    
    [self performSegueWithIdentifier:@"To Car Animation" sender:self];
}

- (void)uploadResults
{
    float TGout = [self.simulationResults[@"TGout"] floatValue];
    float DGout = [self.simulationResults[@"DGout"] floatValue];
    float MGout = [self.simulationResults[@"MGout"] floatValue];
    float Eout = [self.simulationResults[@"Eout"] floatValue];
    float Convout = [self.simulationResults[@"Convout"] floatValue];
    float Cost = [self.simulationResults[@"Cost"] floatValue];
    int mode = [self.simulationResults[@"mode"] intValue];
    float rereact = [self.simulationResults[@"rereact"] floatValue];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"Logged In User"];
    
    if(!username)
    {
        username = @"guest";
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cinnamon.cs.uwp.edu/biodiesel/app_senddata.php?username=%@&inputoil=%d&inputmethanol=%d&inputcatalyst=%d&temp=%d&reacttime=%i&settletime=%i&runtime=%d&tg=%f&dg=%f&mg=%f&esters=%f&conversion=%f&mode=%d&costs=%f&rereact=%f", username, (int)self.initialOil, (int)self.initialMethanol, (int)self.initialCatalyst, (int)self.temperature, (int)self.mixingLength, (int)self.settlingTime, (int)(self.settlingTime + self.mixingLength), TGout, DGout, MGout, Eout, Convout, mode, Cost,rereact]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionTask *task = [session downloadTaskWithRequest:request];
    
    [task resume];
}

#pragma mark - UI Code

- (void)addActivityHUD
{
    self.vialImage.image = [self.vialImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.vialImage setTintColor:self.view.tintColor];

    [self makeViewGlow:self.vialImage color:self.view.tintColor];
    
    [self.vialImage startGlowingWithColor:self.view.tintColor intensity:1.0];
}

- (void)makeViewGlow:(UIView*)view color:(UIColor*)color
{
    view.layer.shadowColor = [color CGColor];
    view.layer.shadowRadius = 5.0f;
    view.layer.shadowOpacity = 0.9;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.masksToBounds = NO;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"To Car Animation"])
    {
        CarAnimationViewController *destination = (CarAnimationViewController*)segue.destinationViewController;
        destination.navigationItem.hidesBackButton = YES;
        
        destination.simulationResults = self.simulationResults;
        destination.gameResults = self.gameResults;
        destination.simulationData = self.simulationData;
    }
}


@end
