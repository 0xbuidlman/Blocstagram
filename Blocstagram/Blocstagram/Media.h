//
//  Media.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LikeButton.h"

typedef NS_ENUM(NSInteger, MediaDownloadState) {
    MediaDownloadStateNeedsImage            = 0,
    MediaDownloadStateDownloadInProgress    = 1,
    MediaDownloadStateNonRecoverableError   = 2,
    MediaDownloadStateHasImage              = 3
};

@class User;

@interface Media : NSObject <NSCoding>

@property (nonatomic) NSString *idNumber;
@property (nonatomic) User *user;
@property (nonatomic) NSURL *mediaURL;
@property (nonatomic) UIImage *image;
@property (nonatomic, assign) MediaDownloadState downloadState;
@property (nonatomic) NSString *caption;
@property (nonatomic) NSArray *comments;
@property (nonatomic) LikeState likeState;
@property (nonatomic) NSNumber *likes;
@property (nonatomic) NSString *temporaryComment;

- (instancetype)initWithDictionary:(NSDictionary *)mediaDictionary;

@end
