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

@interface DataSource()
// @property (nonatomic)  NSArray *mediaItems;
{
                          NSMutableArray *_mediaItems;
}
@property (nonatomic, assign) BOOL isRefreshing;        // Used for Pull to Refresh
@property (nonatomic, assign) BOOL isLoadingOlderItems; // Used for Infinite Scrolling
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
        [self addRandomData];
    }
    return self;
}


#pragma mark - Random Data Generators

- (void)addRandomData {
    NSMutableArray *randomMediaItems = [NSMutableArray array];
    
    for (int i = 1; i <= 10; i++) {
        NSString *imageNamed = [NSString stringWithFormat:@"%d.jpg",i];
        UIImage *image = [UIImage imageNamed:imageNamed];
        
        if (image) {
            Media *media = [[Media alloc] init];
            media.user = [self randomUser];
            media.image = image;
            
            int captionLength = arc4random_uniform(10);
            NSMutableString *caption = [NSMutableString string];
            for (int i = 0; i <= captionLength; i++) {
                NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
                [caption appendFormat:@" %@", randomWord];
            }
            media.caption = caption;
            
            NSUInteger commentCount = arc4random_uniform(10);
            NSMutableArray *randomComments = [NSMutableArray array];
            
            for (int i = 0; i <= commentCount; i++) {
                Comment *randomComment = [self randomComment];
                [randomComments addObject:randomComment];
            }
            
            media.comments = randomComments;
            [randomMediaItems addObject:media];
        }
    }
    
    _mediaItems = randomMediaItems;
}


- (void)removeItem:(Media *)item {
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.mediaItems];
    [newItems removeObject:item];
}

- (User *)randomUser {
    User *user = [[User alloc] init];
    
    user.userName = [self randomStringOfLength:arc4random_uniform(10)];
    
    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7)];
    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12)];
    
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    return user;
}


- (Comment *)randomComment {
    Comment *comment = [[Comment alloc] init];
    
    comment.from = [self randomUser];
    NSUInteger wordCount = arc4random_uniform(20);
    comment.text = [self randomSentenceWithMaximumNumberOfWords:wordCount];

    return comment;
}


- (NSString *)randomStringOfLength:(NSUInteger)length {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    NSMutableString *returnString = [NSMutableString string];
    for (NSUInteger i = 0U; i < length; i++) {
        u_int32_t randomInteger = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar randomCharacter = [alphabet characterAtIndex:randomInteger];
        [returnString appendFormat:@"%C", randomCharacter];
    }
    
    return returnString;
    
}


- (NSString *)randomSentenceWithMaximumNumberOfWords:(NSUInteger)wordCount {
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    
    for (int i = 0; i <= wordCount; i++) {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
        [randomSentence appendFormat:@"%@ ", randomWord];
    }
    
    return randomSentence;
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
    if (!self.isRefreshing) {
        self.isRefreshing = YES;
        Media *media = [[Media alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"10.jpg"];
        media.caption = [self randomSentenceWithMaximumNumberOfWords:arc4random_uniform(7)];
        
        NSMutableArray *randomComments = [NSMutableArray array];
        int commentCount = arc4random_uniform(3);
        for (int i = 0; i <= commentCount; i++) {
            Comment *randomComment = [self randomComment];
            [randomComments addObject:randomComment];
        }
        media.comments = randomComments;
        
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO insertObject:media atIndex:0];
        
        self.isRefreshing = NO;
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}


- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (!self.isLoadingOlderItems) {
        self.isLoadingOlderItems = YES;
        
        Media *media = [[Media alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"1.jpg"];
        media.caption = [self randomSentenceWithMaximumNumberOfWords:arc4random_uniform(7)];
        
        NSMutableArray *randomComments = [NSMutableArray array];
        int commentCount = arc4random_uniform(3);
        for (int i = 0; i <= commentCount; i++) {
            Comment *randomComment = [self randomComment];
            [randomComments addObject:randomComment];
        }
        media.comments = randomComments;
        
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO addObject:media];
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

@end
