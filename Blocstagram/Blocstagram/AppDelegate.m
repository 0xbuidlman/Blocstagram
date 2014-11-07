//
//  AppDelegate.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/7/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagesTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ImagesTableViewController alloc] init] ];
    self.window.backgroundColor = [UIColor colorWithRed:0.667 green:1.000 blue:0.643 alpha:1.000];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
