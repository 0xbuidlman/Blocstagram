//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Dulio Denis on 12/6/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *imageView;

- (instancetype)initWithMedia:(Media *)media;
- (void)centerScrollView;

@end
