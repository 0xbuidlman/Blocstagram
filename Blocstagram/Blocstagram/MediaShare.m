//
//  MediaShare.m
//  Blocstagram
//
//  Created by Dulio Denis on 12/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "MediaShare.h"
#import "Constants.h"

@interface MediaShare ()
@property (nonatomic) UIPopoverController *sharePopover;
@end

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
        if (isPhone) {
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
            [view presentViewController:activityViewController animated:YES completion:nil];
        } else {
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
            UIPopoverController *activityViewControllerPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            activityViewControllerPopover.popoverContentSize = CGSizeMake(320, 568);
            [activityViewControllerPopover presentPopoverFromRect:CGRectMake(0, 0, 0, 0) inView:view.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

@end
