//
//  LikeButton.m
//  Blocstagram
//
//  Created by Dulio Denis on 12/15/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "LikeButton.h"
#import "CircleSpinnerView.h"
#import "Constants.h"

@interface LikeButton()
@property (nonatomic) CircleSpinnerView *spinnerView;
@end

@implementation LikeButton


#pragma mark - initializer

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.spinnerView = [[CircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = LikeStateNotLiked;
    }
    return self;
}


#pragma mark - Update Handling

// Spinners View needs to update when the button's frame changes
- (void)layoutSubviews {
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}


// Update the button based on the button state change
- (void)setLikeButtonState:(LikeState)likeState {
    _likeButtonState = likeState;
    
    NSString *imageName;
    
    switch (_likeButtonState) {
        case LikeStateLiked:
        case LikeStateUnliking:
            imageName = kLikedStateImage;
            break;
            
        case LikeStateNotLiked:
        case LikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState) {
        case LikeStateLiking:
        case LikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case LikeStateLiked:
        case LikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

@end
