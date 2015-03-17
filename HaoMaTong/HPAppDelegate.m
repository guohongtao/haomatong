//
//  HPAppDelegate.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HPAppDelegate.h"
#import "HMTServer.h"
#import "HMTManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "HPViewController.h"
#import "HMTNumberInfo.h"
#import "HPNotificationManager.h"
#import "MTAudioPlayer.h"

@implementation HPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  HPViewController *viewController = [[HPViewController alloc] init];
  
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
  
  self.window.rootViewController = nav;
  
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  
//  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC),dispatch_get_current_queue(), ^{
//        [HPNotificationManager showMessage:@"I'm still alive"];
//  });
  
  return YES;
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  [self continuousServer];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [[HMTManager shared] deactivate];
}

- (void) continuousServer
{
  UIApplication *app = [UIApplication sharedApplication];
  
  // Delay execution of my block for 11 minutes.
//  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 11 * 60 * NSEC_PER_SEC),dispatch_get_current_queue(), ^{
//    [HPNotificationManager showMessage:@"I'm still alive"];
//  });
  
  
  self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
    // Clean up any unfinished task business by marking where you.
    // stopped or ending the task outright.
    [app endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
  }];
  
  // Start the long-running task and return immediately.
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    audioPlayer = [[MTAudioPlayer alloc]init];
    [audioPlayer playBackgroundAudio];

    self.bgTask = UIBackgroundTaskInvalid;
  });
}

@end
