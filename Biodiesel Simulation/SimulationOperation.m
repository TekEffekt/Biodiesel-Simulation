//
//  SimulationOperation.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 10/29/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "SimulationOperation.h"
#import "TheSimulation.h"

@implementation SimulationOperation

- (instancetype)initSimulationWith:(float)oil methanol:(float)methanol catalyst:(float)catalyst temperature:(float)temperature mixingLength:(float)mixingLength andSettlingTime:(float)settlingTime
{
    self = [super init];
    
    self.initialOil = oil;
    self.initialMethanol = methanol;
    self.initialCatalyst = catalyst;
    self.temperature = temperature;
    self.mixingLength = mixingLength;
    self.settlingTime = settlingTime;
    
    return self;
}

- (void)main
{
    @autoreleasepool {
        TheSimulation *simulation = [[TheSimulation alloc] init];
        [simulation initDataWith:self.initialOil methanol:self.initialMethanol catalyst:self.initialCatalyst temperature:self.temperature mixingLength:(float)self.mixingLength andSettlingTime:(float)self.settlingTime];
        [simulation setup];
        
        bool simulationNotDone = YES;
        
        while(simulationNotDone)
        {
            simulationNotDone = [simulation loop];
            
            if(self.isCancelled)
            {
                break;
            }
        }
        
        if(simulationNotDone == NO)
        {
            NSDictionary *results = [simulation getTheResult];
            self.results = results;
            if([self.delegate respondsToSelector:@selector(simulationFinsihed:)])
               {
                   [(NSObject*)self.delegate performSelectorOnMainThread:@selector(simulationFinsihed:) withObject:self waitUntilDone:NO];
               }
        }
    }
}

@end
