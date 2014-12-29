//
//  PageContentViewController.m
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.tutorialText.text = self.titleText;
    self.tutorialText.textAlignment = NSTextAlignmentCenter;
    self.tutorialText.textColor = [UIColor whiteColor];
    self.tutorialText.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:16];
    
    self.pageControl.currentPage = self.pageIndex;
    
    [self firstTimeFadeIn];
}

- (void)firstTimeFadeIn
{
    if(![[NSUserDefaults standardUserDefaults] integerForKey:@"Faded In"])
    {
        self.backgroundImageView.alpha = 0.0;
        self.tutorialText.alpha = 0.0;
        
        [UIView animateWithDuration:1.0 animations:^{
            self.backgroundImageView.alpha = 1.0;
        }];
        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.tutorialText.alpha = 1.0;
        } completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"Faded In"];
    }
}

@end
