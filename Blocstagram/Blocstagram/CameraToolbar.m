//
//  CameraToolbar.m
//  Blocstagram
//
//  Created by Dulio Denis on 1/18/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import "CameraToolbar.h"

@interface CameraToolbar()

@property (nonatomic) UIButton *leftButton;
@property (nonatomic) UIButton *rightButton;
@property (nonatomic) UIButton *cameraButton;

@property (nonatomic) UIView *whiteView;
@property (nonatomic) UIView *purpleView;

@end

@implementation CameraToolbar

- (instancetype)initWithImageNames:(NSArray *)imageNames {
    self = [super init];
    
    if (self) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.leftButton addTarget:self action:@selector(leftButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftButton setImage:[UIImage imageNamed:imageNames.firstObject] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:imageNames.lastObject] forState:UIControlStateNormal];
        
        [self.cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self.cameraButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 15, 10)];
        
        self.whiteView = [[UIView alloc] init];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        
        self.purpleView = [[UIView alloc] init];
        self.purpleView.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1];
        
        for (UIView *view in @[self.whiteView, self.purpleView, self.leftButton, self.rightButton, self.cameraButton]) {
            [self addSubview:view];
        }
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect whiteFrame = self.bounds;
    whiteFrame.origin.y += 10;
    self.whiteView.frame = whiteFrame;
    
    CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 3;
    
    NSArray *buttons = @[self.leftButton, self.cameraButton, self.rightButton];
    for (int i = 0; i < 3; i++) {
        UIButton *button = buttons[i];
        button.frame = CGRectMake(i * buttonWidth, 10, buttonWidth, CGRectGetHeight(whiteFrame));
    }
    
    self.purpleView.frame = CGRectMake(buttonWidth, 0, buttonWidth, CGRectGetHeight(self.bounds));
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.purpleView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.purpleView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.purpleView.layer.mask = maskLayer;
}


#pragma mark - Button Handlers

- (void) leftButtonPressed:(UIButton *)sender {
    [self.delegate leftButtonPressedOnToolbar:self];
}

- (void) rightButtonPressed:(UIButton *)sender {
    [self.delegate rightButtonPressedOnToolbar:self];
}

- (void) cameraButtonPressed:(UIButton *)sender {
    [self.delegate cameraButtonPressedOnToolbar:self];
}

@end
