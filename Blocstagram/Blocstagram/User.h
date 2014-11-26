//
//  User.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject <NSCoding>

@property (nonatomic) NSString *idNumber;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *fullName;
@property (nonatomic) NSURL *profilePictureURL;
@property (nonatomic) UIImage *profilePicture;

- (instancetype)initWithDictionary:(NSDictionary *)userDictionary;

@end
