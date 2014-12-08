//
//  MediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Dulio Denis on 12/6/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting; // YES or NO=dismissing
@property (nonatomic, weak) UIImageView *cellImageView;

@end
