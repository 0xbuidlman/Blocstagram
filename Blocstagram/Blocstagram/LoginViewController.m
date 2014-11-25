//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/16/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, assign) BOOL isLoginPage;

@end

@implementation LoginViewController

NSString *const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";
NSString *loginPageStart = @"https://instagram.com/oauth/authorize/";

#pragma mark - View Lifecycle

- (void)loadView {
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    self.webView = webView;
    self.view = webView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    
    [self gotoLoginPage];
}


- (NSString *)redirectURI {
    return @"blocstagram://auth/instagram";
}


-(void)gotoLoginPage {
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [DataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
    self.isLoginPage = YES;
}


- (void)goBackToLogin:(id)sender {
    [self gotoLoginPage];
}


#pragma mark - WebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
                                                 navigationType:(UIWebViewNavigationType)navigationType {
    if ( ![[request.URL absoluteString] containsString:@"login"]
        && ![[request.URL absoluteString] containsString:loginPageStart] ) {
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleDone target:self action:@selector(goBackToLogin:)];
        
        self.navigationItem.leftBarButtonItem = homeButton;
        self.isLoginPage = NO;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
 
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:[self redirectURI]]) {
        // This contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    }
    
    return YES;
}


#pragma mark - Dealloc and Clear Instagram Cookies
- (void)dealloc {
    [self clearInstagramCookies];
    // Dealloc in order to set webView delegate to nil
    self.webView.delegate = nil;
}


/**
 Clears Instagram cookies. This prevents caching the credentials in the cookie jar.
 */
- (void)clearInstagramCookies {
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if(domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

@end
