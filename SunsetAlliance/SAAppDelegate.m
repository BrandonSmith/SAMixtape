//
//  SAAppDelegate.m
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "SAAppDelegate.h"
#import "GAI.h"

#ifdef DEBUG
#define GA @"UA-25371300-2"
#define VSN_SUFFIX @"+debug"
#else
#define GA @"UA-25371300-2"
#define VSN_SUFFIX @"+release"
#endif

@implementation SAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:urlCache];
    
    NSString *build = [[NSBundle mainBundle]infoDictionary][@"CFBundleVersion"];
    NSString *version = [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"];
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@%@", version, build, VSN_SUFFIX];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 1;
    [GAI sharedInstance].debug = YES;
    id<GAITracker> tracker = [[GAI sharedInstance]trackerWithTrackingId:GA];
    tracker.sessionTimeout = 5400; // set session timeout 90 minutes
    tracker.appVersion = appVersion;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
