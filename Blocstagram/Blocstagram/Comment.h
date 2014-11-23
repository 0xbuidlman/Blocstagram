//
//  Comment.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class User;

@interface Comment : NSObject

@property (nonatomic) NSString *idNumber;
@property (nonatomic) User *from;
@property (nonatomic) NSString *text;

- (instancetype)initWithDictionary:(NSDictionary *)commentDictionary;

@end
