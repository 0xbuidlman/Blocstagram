//
//  Media.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class User;

@interface Media : NSObject <NSCoding>

@property (nonatomic) NSString *idNumber;
@property (nonatomic) User *user;
@property (nonatomic) NSURL *mediaURL;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *caption;
@property (nonatomic) NSArray *comments;

- (instancetype)initWithDictionary:(NSDictionary *)mediaDictionary;

@end
