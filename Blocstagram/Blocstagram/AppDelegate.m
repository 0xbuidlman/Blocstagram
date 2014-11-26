//
//  AppDelegate.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/7/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagesTableViewController.h"
#import "LoginViewController.h"
#import "DataSource.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [DataSource sharedInstance];
    
    UINavigationController *navViewController = [[UINavigationController alloc] init];
    
    if (![DataSource sharedInstance].accessToken) {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        
        [navViewController setViewControllers:@[loginViewController] animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            ImagesTableViewController *imagesViewController = [[ImagesTableViewController alloc] init];
            [navViewController setViewControllers:@[imagesViewController] animated:YES];
        }];
    } else {
        ImagesTableViewController *imageVC = [[ImagesTableViewController alloc] init];
        [navViewController setViewControllers:@[imageVC] animated:YES];
    }
    
    self.window.rootViewController = navViewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
