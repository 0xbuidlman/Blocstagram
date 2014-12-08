//
//  MediaFullScreenAnimator.m
//  Blocstagram
//
//  Created by Dulio Denis on 12/6/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "MediaFullScreenAnimator.h"
#import "MediaFullScreenViewController.h"

@implementation MediaFullScreenAnimator


#pragma mark - Animation Duration

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}


#pragma mark - Animation Transition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {
        MediaFullScreenViewController *fullScreenViewController = (MediaFullScreenViewController *)toViewController;
        
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect startFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        CGRect endFrame = fromViewController.view.frame;
        
        toViewController.view.frame = startFrame;
        fullScreenViewController.imageView.frame = toViewController.view.bounds;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            fullScreenViewController.view.frame = endFrame;
            [fullScreenViewController centerScrollView];
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        MediaFullScreenViewController *fullScreenViewController = (MediaFullScreenViewController *)fromViewController;
        
        CGRect endFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        CGRect imageStartFrame = [fullScreenViewController.view convertRect:fullScreenViewController.imageView.frame fromView:fullScreenViewController.scrollView];
        CGRect imageEndFrame = [transitionContext.containerView convertRect:endFrame fromView:fullScreenViewController.view];
        
        imageEndFrame.origin.y = 0;
        
        [fullScreenViewController.view addSubview:fullScreenViewController.imageView];
        fullScreenViewController.imageView.frame = imageStartFrame;
        fullScreenViewController.imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        toViewController.view.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fullScreenViewController.view.frame = endFrame;
            fullScreenViewController.imageView.frame = imageEndFrame;
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
