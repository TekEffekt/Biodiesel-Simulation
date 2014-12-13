//
//  GasGaugeNode.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/15/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "GasGaugeNode.h"

@interface GasGaugeNode ()

@property(strong, nonatomic) SKSpriteNode *needle;
@property(nonatomic) CGFloat needleAngle;

@end

@implementation GasGaugeNode

#define OFF_SET -30

#pragma mark - Initializers
- (instancetype)init
{
    self = [GasGaugeNode spriteNodeWithImageNamed:@"Gas Gauge"];
    self.needle = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(self.size.width/50, self.size.height/1.2)];
    self.needle.position = CGPointMake(CGRectGetMidX(self.frame), OFF_SET);
    self.needle.anchorPoint = CGPointMake(CGRectGetMidX(self.needle.frame), 0);
    
     // the needle starts upwards so it needs to point to the left 90 degrees
    self.needleAngle = M_PI/2;
    [self.needle runAction:[SKAction rotateToAngle:self.needleAngle duration:0.0]];
    
    [self addChild:self.needle];
    return self;
}

#pragma mark - Graphics
- (void)moveGaugeToAngle:(CGFloat)angle withDuration:(CGFloat)duration
{
    self.needleAngle = angle;
    
    SKAction *rotation = [SKAction rotateToAngle:self.needleAngle duration:duration];
    [self.needle runAction:rotation completion:^(void){ self.needleDoneMoving = YES; } ];
}

@end
