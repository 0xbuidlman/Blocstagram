//
//  DataSource.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

@property (nonatomic, readonly) NSArray *mediaItems;
@property (nonatomic, readonly) NSString *accessToken;

+ (NSString *)instagramClientID;
+ (instancetype)sharedInstance;
- (void)deleteMediaItem:(Media *)item;

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void)downloadImageForMediaItem:(Media *)mediaItem;
- (void)toggleLikeOnMediaItem:(Media *)mediaItem;

@end
