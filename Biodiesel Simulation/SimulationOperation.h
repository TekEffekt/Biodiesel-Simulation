//
//  SimulationOperation.h
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 10/29/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SimulationController;

@interface SimulationOperation : NSOperation

@property (nonatomic, assign) id<SimulationController> delegate;

@property(nonatomic) float initialOil;
@property(nonatomic) float initialMethanol;
@property(nonatomic) float initialCatalyst;
@property(nonatomic) float temperature;
@property(nonatomic) float settlingTime;
@property(nonatomic) float mixingLength;

@property(strong, nonatomic) NSDictionary *results;

- (instancetype)initSimulationWith:(float)oil methanol:(float)methanol catalyst:(float)catalyst temperature:(float)temperature mixingLength:(float)mixingLength andSettlingTime:(float)settlingTime;
@end

@protocol SimulationController <NSObject>

- (void)simulationFinsihed:(SimulationOperation*)operation;

@end