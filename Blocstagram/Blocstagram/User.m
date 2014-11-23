//
//  User.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)userDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = userDictionary[@"id"];
        self.userName = userDictionary[@"username"];
        self.fullName = userDictionary[@"full_name"];
        
        NSString *profileURLString = userDictionary[@"profile_picture"];
        NSURL *profileURL = [NSURL URLWithString:profileURLString];
        
        if (profileURLString) {
            self.profilePictureURL = profileURL;
        }
    }
    return self;
}

@end
