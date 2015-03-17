//
//  HPNotificationManager.h
//  HaoMaTong
//
//  Created by HongTao Guo on 15/2/27.
//  Copyright (c) 2015年 guohongtao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPNotificationManager : NSObject
+(instancetype)sharedManager;
+ (void)showMessage:(NSString*)message;
@end
