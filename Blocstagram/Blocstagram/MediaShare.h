//
//  MediaShare.h
//  Blocstagram
//
//  Created by Dulio Denis on 12/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaShare : NSObject
+ (void)share:(UIViewController *)view withCaption:(NSString *)caption withImage:(UIImage *)image;
@end
