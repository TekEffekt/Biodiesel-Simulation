//
//  PageContentViewController.h
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextView *tutorialText;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (void)firstTimeFadeIn;

@end
