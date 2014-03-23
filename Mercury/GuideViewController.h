//
//  GuideViewController.h
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GuideContentView.h"

@interface GuideViewController : UIViewController

@property (strong, nonatomic) GuideContentView *guideView;
@property (strong, nonatomic) NSArray *panels;
@property (assign, nonatomic) BOOL skipEnabled;

+ (NSArray *)defaultPanels;
+ (instancetype)defaultGuideViewController;
+ (instancetype)skipGuideViewController;

- (instancetype)initWithPanels:(NSArray *)panels skip:(BOOL)skip;

@end
