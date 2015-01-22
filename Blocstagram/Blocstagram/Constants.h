//
//  Constants.h
//  Blocstagram
//
//  Created by Dulio Denis on 12/11/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#ifndef Blocstagram_Constants_h
#define Blocstagram_Constants_h

#import <Availability.h>

// String Constants
static NSString *kAppTitle = @"Blocstagram";
static NSString *kInstagramAPI = @"https://api.instagram.com/v1/";
static NSString *kInstagramUserGetPath = @"users/self/feed";
static NSString *kKeyChainAccessToken = @"access_token";
static NSString *kInstagramClientID = @"b9f77d8242aa430790426b886687d183";

static NSString *const kLoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";
static NSString *const kLikesNotification = @"LikesNotification";
static NSString *const kLoginPageStart = @"https://instagram.com/oauth/authorize/";
static NSString *const kLoginStringFormat = @"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token";

static NSString *kLikedStateImage = @"heart-full";
static NSString *kUnlikedStateImage = @"heart-empty";

// Font Constants
static NSString *kLightFont = @"HelveticaNeue-Thin";
static NSString *kBoldFont = @"HelveticaNeue-Bold";

// Value Constants
static const float kTransitionDuration = 0.3;

// Old Fashioned Idiom-based Device Detection
#define isPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#ifndef __IPHONE_3_0
#warning "This project uses features only available in iOS SDK 3.0 and later."
#endif

#endif
