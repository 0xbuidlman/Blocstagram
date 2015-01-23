//
//  ComposeCommentViewTests.m
//  Blocstagram
//
//  Created by Dulio Denis on 1/23/15.
//  Copyright (c) 2015 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ComposeCommentView.h"

@interface ComposeCommentViewTests : XCTestCase

@end

@implementation ComposeCommentViewTests

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


- (void)testComposeCommentViewSetText {
    ComposeCommentView *testCommentView = [[ComposeCommentView alloc] init];
    [testCommentView setText:@"test Text"];
    
    XCTAssertEqual(testCommentView.isWritingComment, (BOOL)YES, @"ComposeCommentView correctly set the isWritingComment when there is text.");
}


- (void)testComposeCommentViewSetNoText {
    ComposeCommentView *testCommentView = [[ComposeCommentView alloc] init];
    
    XCTAssertEqual(testCommentView.isWritingComment, (BOOL)NO, @"ComposeCommentView correctly set the isWritingComment to No when there is no text.");
}


@end
