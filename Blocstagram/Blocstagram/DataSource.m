//
//  DataSource.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"

@interface DataSource()
{
                          NSMutableArray *_mediaItems;
}
@property (nonatomic) NSString *accessToken;
@property (nonatomic, assign) BOOL isRefreshing;        // Used for Pull to Refresh
@property (nonatomic, assign) BOOL isLoadingOlderItems; // Used for Infinite Scrolling
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages; // Used to prevent pointless requests
@end

@implementation DataSource

#pragma mark - Singleton Shared Instance Class Method & Initialization

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self registerForAccessTokenNotification];
    }
    return self;
}


#pragma mark - the Instagram Client ID

+(NSString *)instagramClientID {
    return @"b9f77d8242aa430790426b886687d183";
}


#pragma mark - AccessToken Notification Registration
- (void)registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
    }];
    
    // Received token now populate the initial data
    [self populateDataWithParameters:nil completionHandler:nil];
}


#pragma mark - Key / Value Observing

- (NSUInteger)countOfMediaItems {
    return self.mediaItems.count;
}


- (id)objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}


- (NSArray *)mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}


#pragma mark - Mutable Accessor Methods for KVC

- (void)insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}


- (void)removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}


- (void)replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}


#pragma mark - Delete Method for KVO

- (void)deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}


#pragma mark - Pull To Refresh & Infinite Scrolling Methods

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    self.thereAreNoMoreOlderMessages = NO;
    
    if (!self.isRefreshing) {
        self.isRefreshing = YES;
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters = [NSDictionary dictionary];
        if (minID) {
            parameters = @{@"min_id": minID};
        }
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}


- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (!self.isLoadingOlderItems && !self.thereAreNoMoreOlderMessages) {
        self.isLoadingOlderItems = YES;
        
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters = @{@"max_id": maxID};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}


#pragma mark - Instagram API Requests

- (void)populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in a background thread so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                // for example: if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData) {
                        NSError *jsonError;
                        NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                        
                        if (feedDictionary) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // done networking, go back on the main thread
                                [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                                if (completionHandler) {
                                    completionHandler(nil);
                                }
                            });
                        } else if (completionHandler) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completionHandler(jsonError);
                            });
                        }
                    } else if (completionHandler) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(webError);
                    });
                }
            }
        });
    }
}


- (void)parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // this was a pull to refresh request
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewItems = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewItems];
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll since there are no more older messages
            self. thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        _mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
}


- (void)downloadImageForMediaItem:(Media *)mediaItem {
    // if we have a URL but no image
    if (mediaItem.mediaURL && !mediaItem.image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse *response;
            NSError *error;
            
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                    });
                }
            } else {
                NSLog(@"Error downloading image");
            }
        });
    }
}

@end

