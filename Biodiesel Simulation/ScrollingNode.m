//
//  ScrollingNode.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/15/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "ScrollingNode.h"

@implementation ScrollingNode

+ (id) scrollingNodeWithImageNamed:(NSString *)name inContainerWidth:(float) width
{
    UIImage * image = [UIImage imageNamed:name];
    
    ScrollingNode *realNode =
        [ScrollingNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(width, image.size.height)];
    realNode.scrollingSpeed = 0;
    
    float total = 0;
    while(total<(width + image.size.width)){
        SKSpriteNode * child = [SKSpriteNode spriteNodeWithImageNamed:name ];
        [child setAnchorPoint:CGPointZero];
        [child setPosition:CGPointMake(total, 0)];
        [realNode addChild:child];
        total+=child.size.width;
    }
    
    return realNode;
}

- (void) update:(NSTimeInterval)currentTime
{
    [self.children enumerateObjectsUsingBlock:^(SKSpriteNode * child, NSUInteger idx, BOOL *stop) {
        child.position = CGPointMake(child.position.x-self.scrollingSpeed, child.position.y);
        if (child.position.x <= -child.size.width){
            float delta = child.position.x+child.size.width;
            child.position =
                CGPointMake(child.size.width*(self.children.count-1)+delta, child.position.y);
        }
    }];
}

@end
