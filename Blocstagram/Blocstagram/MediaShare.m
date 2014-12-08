//
//  MediaShare.m
//  Blocstagram
//
//  Created by Dulio Denis on 12/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "MediaShare.h"

@implementation MediaShare

+ (void)share:(UIViewController *)view withCaption:(NSString *)caption withImage:(UIImage *)image {
    NSMutableArray *itemsToShare = [NSMutableArray array];

    if (caption.length > 0) {
        [itemsToShare addObject:caption];
    }
    
    if (image) {
        [itemsToShare addObject:image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [view presentViewController:activityViewController animated:YES completion:nil];
    }
}

@end
