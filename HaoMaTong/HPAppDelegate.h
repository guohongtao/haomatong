//
//  HPAppDelegate.h
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTAudioPlayer;

@interface HPAppDelegate : UIResponder <UIApplicationDelegate> {
  MTAudioPlayer *audioPlayer;
}

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;


@end
