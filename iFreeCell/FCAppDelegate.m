//
//  FCAppDelegate.m
//  iFreeCell
//
//  Created by Miguel Estévez on 03/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCAppDelegate.h"

@implementation FCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // [[FCGameState shared] restoreState];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[FCGameState shared] saveState];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // [[FCGameState shared] restoreState];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[FCGameState shared] saveState];
}

@end
