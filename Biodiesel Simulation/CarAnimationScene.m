//
//  CarAnimationScene.m
//  Biodiesel Simulation
//
//  Created by App Factory on 11/14/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "CarAnimationScene.h"
#import "GasGaugeNode.h"
#import "ScrollingNode.h"
#import "CarDistanceGame.h"

@interface CarAnimationScene () <AVAudioPlayerDelegate>

@property(strong, nonatomic) ScrollingNode *background;
@property(strong, nonatomic) GasGaugeNode *gasGauge;
@property(strong, nonatomic) SKLabelNode *gasFillingLabel;
@property(strong, nonatomic) SKSpriteNode *car;
@property(nonatomic) BOOL carAnimationStarted; 
@property(nonatomic) BOOL timerStarted;
@property(nonatomic) BOOL carAnimationStopped;

@property(strong, nonatomic) AVAudioPlayer *highScoreSound;
@property(strong, nonatomic) AVAudioPlayer *carStartSound;
@property(strong, nonatomic) AVAudioPlayer *driveAwaySound;
@property(strong, nonatomic) AVAudioPlayer *carWontStartSound;

@end

@implementation CarAnimationScene

#define Max Car Speed 30

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

- (AVAudioPlayer*)carStartSound
{
    if(!_carStartSound)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"carStart" ofType:@"mp3"]];
        _carStartSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _carStartSound.delegate = self;
        [_carStartSound prepareToPlay];
    }
    
    return _carStartSound;
}

- (AVAudioPlayer*)driveAwaySound
{
    if(!_driveAwaySound)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"carDriveOff" ofType:@"mp3"]];
        _driveAwaySound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error: nil];
        [_driveAwaySound prepareToPlay];
    }
    
    return _driveAwaySound;
}

- (AVAudioPlayer*)carWontStartSound
{
    if(!_carWontStartSound)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CarWontStart" ofType:@"mp3"]];
        _carWontStartSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _carWontStartSound.delegate = self;
        [_carWontStartSound prepareToPlay];
    }
    
    return _carWontStartSound;
}

#pragma mark - Scene Life Cycle
- (void)didMoveToView:(SKView *)view
{
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    [self addChild:self.background];
    [self addChild:self.gasGauge];
    [self addChild:self.car];
    
    [self fillGasTankAnimation];
}

- (void)update:(NSTimeInterval)currentTime
{
    if(self.gasGauge.needleDoneMoving && !self.carAnimationStarted && !self.timerStarted)
    {
        [self makeGasFillingLabelFadeOut];
        
        NSString *fuelQuality = (NSString*)self.gameResults[@"Fuel Quality"];
        
        if([fuelQuality isEqualToString:@"Yes"])
        {
            [self playCarStartFailedAnimation];
        } else
        {
            self.gasGauge.needleDoneMoving = NO;
            [self.carStartSound play];
        }
    } else if(self.carAnimationStarted && self.background.scrollingSpeed < 60)
    {
        self.background.scrollingSpeed *= 1.05; // gradually speed up the car
        [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(stopCarAnimation:) userInfo:nil repeats:NO];
        [self.gasGauge moveGaugeToAngle:M_PI/2 withDuration:6.0];
        self.timerStarted = YES;
    } else if(self.carAnimationStopped && self.background.scrollingSpeed > 0)
    {
        self.background.scrollingSpeed -= 0.35; // gradually slow down the car

    } else if(self.background.scrollingSpeed < 0)
    {
        self.background.scrollingSpeed = 0.0;
        [self.car removeAllActions];
        
        if([CarDistanceGame checkDistanceForLevelUp:[self.gameResults[@"Distance"] floatValue] andStoreLevelUpInfo:NO])
        {
            [self.car addChild:[self getSpark]];
            [self.highScoreSound play];
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sparkDone:) userInfo:nil repeats:NO];
        } else
        {
            if([self.delegate respondsToSelector:@selector(animationFinished:)])
            {
                [(NSObject*)self.delegate performSelectorOnMainThread:@selector(animationFinished:) withObject:self waitUntilDone:NO];
            }
        }
    }
    [self.background update:currentTime];
}

- (void)sparkDone:(NSTimer*)timer
{
    if([self.delegate respondsToSelector:@selector(animationFinished:)])
    {
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(animationFinished:) withObject:self waitUntilDone:NO];
    }
}

#pragma mark - Setters and Getters
- (ScrollingNode*)background
{
    if(!_background)_background = [ScrollingNode scrollingNodeWithImageNamed:@"Road Background" inContainerWidth:self.frame.size.width];
    return _background;
}

- (GasGaugeNode*)gasGauge
{
    if(!_gasGauge)_gasGauge = [[GasGaugeNode alloc] init];
    _gasGauge.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/1.5);
    return _gasGauge;
}

- (SKSpriteNode*)car
{
    if(!_car)_car = [SKSpriteNode spriteNodeWithImageNamed:@"Car"];
    _car.position = CGPointMake(self.frame.size.width/2, self.frame.size.width/4);
    return _car;
}

#pragma mark - Node factory methods
- (SKEmitterNode*)getSmoke
{
    NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
    
    return smoke;
}

- (SKEmitterNode*)getSpark
{
    NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"Level Up Effect" ofType:@"sks"];
    SKEmitterNode *spark = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
    
    spark.numParticlesToEmit = 500;
    
    return spark;
}

- (SKLabelNode*)getGasFillingLabel
{
    SKLabelNode *label = [SKLabelNode labelNodeWithText:@"Filling the car with your gas!"];
    label.fontSize = 23;
    label.fontName = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].fontName;
    SKAction *fadeOutAction = [SKAction fadeOutWithDuration:0.7];
    SKAction *fadeInAction = [SKAction fadeInWithDuration:0.7];
    
    SKAction *blinkingAction = [SKAction sequence:@[fadeOutAction, fadeInAction]];
    
    [label runAction:[SKAction repeatActionForever:blinkingAction]];
    
    return label;
}

#pragma mark - Animation
- (void)startCarAnimation
{
    SKTextureAtlas *carAtlas = [SKTextureAtlas atlasNamed:@"car"];
    
    SKTexture *car1 = [carAtlas textureNamed:@"car1"];
    SKTexture *car2 = [carAtlas textureNamed:@"car2"];
    SKTexture *car3 = [carAtlas textureNamed:@"car3"];
    
    NSArray *animation = @[car1, car2, car3];
    
    SKAction *movingAnimation = [SKAction animateWithTextures:animation timePerFrame:0.1];
    
    [self.car runAction:[SKAction repeatActionForever:movingAnimation]];
    
    SKEmitterNode *smoke = [self getSmoke];
    
    smoke.position = CGPointMake(self.car.position.x - self.car.size.width/2, self.frame.size.width/4);
    [self removeAllChildren];
    [self addChild:self.background];
    [self addChild:smoke];
    [self addChild:self.car];
    [self addChild:self.gasGauge];
    
    self.background.scrollingSpeed = 1;
    self.carAnimationStarted = YES;
}

- (CGFloat)getAngleForGas:(CGFloat)gallonsOfGas
{
    NSLog(@"Gallons:%f", gallonsOfGas);
    CGFloat angle = (M_PI/2) - (M_PI/300 * gallonsOfGas);
    return angle;
}

- (void)fillGasTankAnimation
{
    CGFloat gas = [self.gameResults[@"Gallons"] floatValue];
    CGFloat angle = [self getAngleForGas:gas];
    
    [self.gasGauge moveGaugeToAngle:angle withDuration:[self.gameResults[@"Gallons"] floatValue]/50.0];
    
    self.gasFillingLabel = [self getGasFillingLabel];
    self.gasFillingLabel.position = CGPointMake(CGRectGetMidX(self.gasGauge.frame), self.gasGauge.position.y + self.gasGauge.size.height);
    
    [self addChild:self.gasFillingLabel];
}

- (void)stopCarAnimation:(NSTimer *)timer
{
    self.carAnimationStopped = YES;
    self.carAnimationStarted = NO;
    self.gasGauge.needleDoneMoving = NO;
    
    [self.scene removeAllChildren];
    [self addChild:self.background];
    [self addChild:self.car];
    [self addChild:self.gasGauge];
}

// The effect that plays when the fuel's conversion ration is below 50%
- (void)playCarStartFailedAnimation
{
    [self.carWontStartSound play];
    self.gasGauge.needleDoneMoving = NO;
}

- (void)makeGasFillingLabelFadeOut
{
    SKAction *fadeOut = [SKAction fadeOutWithDuration:1.0];
    
    [self.gasFillingLabel runAction:fadeOut];
    [self.gasFillingLabel removeFromParent];
}

#pragma mark - Audio Methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(player == self.carStartSound)
    {
        [self startCarAnimation];
        [self.driveAwaySound play];
    } else if(player == self.carWontStartSound)
    {
        self.simulationFailed = YES;
        
        if([self.delegate respondsToSelector:@selector(animationFinished:)])
        {
            [(NSObject*)self.delegate performSelectorOnMainThread:@selector(animationFinished:) withObject:self waitUntilDone:NO];
        }
    }
}

@end
