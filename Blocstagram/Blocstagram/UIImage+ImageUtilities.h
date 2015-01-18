//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Dulio Denis on 1/18/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *)imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;
- (UIImage *)imageWithFixedOrientation;
- (UIImage *)imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *)imageCroppedToRect:(CGRect)cropRect;

@end
