//
//  CarAnimationScene.h
//  Biodiesel Simulation
//
//  Created by App Factory on 11/14/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol CarAnimationController;

@interface CarAnimationScene : SKScene

@property(strong, nonatomic) NSDictionary *gameResults;
@property(assign, nonatomic) id<CarAnimationController> delegate;

@end

@protocol CarAnimationController <NSObject>

- (void)animationFinished:(CarAnimationScene*)scene;

@end
