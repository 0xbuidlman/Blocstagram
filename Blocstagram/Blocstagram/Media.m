//
//  Media.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"

@implementation Media

- (instancetype)initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImagesURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURLString) {
            self.mediaURL = standardResolutionImagesURL;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Captions may be null if there are no captions
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else { // it must be an NSNull
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentDictionary];
            [commentsArray addObject:comment];
        }
        self.comments = commentsArray;
    }
    return self;
}

@end
