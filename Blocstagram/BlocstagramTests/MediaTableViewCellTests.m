//
//  MediaTableViewCellTests.m
//  Blocstagram
//
//  Created by Dulio Denis on 1/23/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MediaTableViewCell.h"
#import "Media.h"
#import "User.h"

@interface MediaTableViewCellTests : XCTestCase

@end

@implementation MediaTableViewCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testThatInitializationWorks {
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"user" : @{@"id": @"8675309",
                                                   @"username" : @"d'oh",
                                                   @"full_name" : @"Homer Simpson",
                                                   @"profile_picture" : @"http://www.example.com/example.jpg"},
                                       @"images" : @{@"standard_resolution" : @{@"url" : @"http://distillery.s3.amazonaws.com/media/2010/07/16/4de37e03aa4b4372843a7eb33fa41cad_7.jpg"}},
                                       @"caption" : @{@"text" : @"this is a caption"},
                                       @"comments" : @{@"data" : @[@{@"text" : @"one comment"}, @{@"text" : @"second comment"}]},
                                       @"user_has_liked" : @"true",
                                       @"likes" : @{@"count" : @10}};

    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testMedia.user.idNumber, sourceDictionary[@"user"][@"id"], @"The user id should be equal");
    XCTAssertEqualObjects(testMedia.user.userName, sourceDictionary[@"user"][@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testMedia.user.fullName, sourceDictionary[@"user"][@"full_name"], @"The user full name should be equal");
    XCTAssertEqualObjects(testMedia.user.profilePictureURL.absoluteString, sourceDictionary[@"user"][@"profile_picture"], @"The user profile picture should be equal");
    XCTAssertEqualObjects(testMedia.mediaURL.absoluteString, sourceDictionary[@"images"][@"standard_resolution"][@"url"], @"The image url should match");
    XCTAssertEqualObjects(testMedia.caption, sourceDictionary[@"caption"][@"text"], @"The caption text should match");
}

- (void)testMediaTableViewCellHeightForMediaItem {
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"user" : @{@"id": @"8675309",
                                                   @"username" : @"d'oh",
                                                   @"full_name" : @"Homer Simpson",
                                                   @"profile_picture" : @"http://www.example.com/example.jpg"},
                                       @"images" : @{@"standard_resolution" : @{@"url" : @"http://distillery.s3.amazonaws.com/media/2010/07/16/4de37e03aa4b4372843a7eb33fa41cad_7.jpg"}},
                                       @"caption" : @{@"text" : @"this is a caption"},
                                       @"comments" : @{},
                                       @"user_has_liked" : @"true",
                                       @"likes" : @{@"count" : @10}};
    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    testMedia.image = [UIImage imageNamed:@"1.jpg"];
    CGFloat cellHeight = [MediaTableViewCell heightForMediaItem:testMedia width:[UIScreen mainScreen].bounds.size.width];
    XCTAssertNotEqual(cellHeight, testMedia.image.size.height, @"the height should not be equal");
}

@end
