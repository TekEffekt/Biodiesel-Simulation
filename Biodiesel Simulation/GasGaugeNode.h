//
//  GasGaugeNode.h
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/15/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GasGaugeNode : SKSpriteNode

- (void)moveGaugeToAngle:(CGFloat)angle withDuration:(CGFloat)duration;

@property (nonatomic) BOOL needleDoneMoving;

@end
