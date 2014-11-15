//
//  DataSource.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Media;

@interface DataSource : NSObject

@property (nonatomic, readonly) NSArray *mediaItems;

+ (instancetype)sharedInstance;
- (void)removeItem:(Media *)item; // legacy method
- (void)deleteMediaItem:(Media *)item;

@end
