//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Dulio Denis on 12/6/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"
#import "MediaShare.h"
#import "Constants.h"

@interface MediaFullScreenViewController () <UIScrollViewDelegate>

// Gesture Recognizers
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic) UITapGestureRecognizer *doubleTap;

// to dismiss the iPad view when user taps on grey border
@property (nonatomic) UITapGestureRecognizer *tapBehind;

@end

@implementation MediaFullScreenViewController


#pragma mark - Object Initialization

- (instancetype)initWithMedia:(Media *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // The Scroll View
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    // The ImageView inside the ScrollView
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = self.media.image;
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.media.image.size;
    
    // The Gesture Recognizers
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    if (isPhone == NO) {
        self.tapBehind = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehindFired:)];
        self.tapBehind.cancelsTouchesInView = NO;
    }
}


// Method for creating Share Button
- (void)addShareButton {
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [shareButton addTarget:self
                    action:@selector(shareButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(300.0, 40.0, 80.0, 80.0);
    [self.view addSubview:shareButton];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    [self recalculateZoomScale];
}


- (void)recalculateZoomScale {
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    scrollViewContentSize.height /= self.scrollView.zoomScale;
    scrollViewContentSize.width /= self.scrollView.zoomScale;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minimumScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minimumScale;
    self.scrollView.maximumZoomScale = 2;
    
    [self addShareButton];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self centerScrollView];
    
    if (isPhone == NO) {
        [[[[UIApplication sharedApplication] delegate] window] addGestureRecognizer:self.tapBehind];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (isPhone == NO) {
        [[[[UIApplication sharedApplication] delegate] window] removeGestureRecognizer:self.tapBehind];
    }
}


#pragma mark - ScrollView Centering

- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = ((boundsSize.width - CGRectGetWidth(contentsFrame)) / 2);
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = ((boundsSize.height - CGRectGetHeight(contentsFrame)) / 2);
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}


#pragma mark - ScrollView Delegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}


#pragma mark - Gesture Recognizers

- (void)tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}


- (void)tapBehindFired:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [sender locationInView:nil]; // Passing nil gives us coordinates in the window
        CGPoint locationInVC = [self.presentedViewController.view convertPoint:location fromView:self.view.window];
        
        if ([self.presentedViewController.view pointInside:locationInVC withEvent:nil] == NO) {
            // The tap was outside the VC's view
            
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}


#pragma mark - Share Button Action

- (void)shareButtonPressed:(UIButton *)sender {
    [MediaShare share:self withCaption:self.media.caption withImage:self.media.image];
}

@end
