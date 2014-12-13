//
//  ScrollingNode.h
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/15/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ScrollingNode : SKSpriteNode

@property (nonatomic) CGFloat scrollingSpeed;

+ (id) scrollingNodeWithImageNamed:(NSString *)name inContainerWidth:(float) width;
- (void) update:(NSTimeInterval)currentTime;

@end
