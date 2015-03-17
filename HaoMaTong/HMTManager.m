//
//  HMTManager.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HMTManager.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import "HMTServer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HMTNumberInfo.h"
#import "HPNotificationManager.h"

//来电状态
typedef NS_ENUM (int, CTCallStatus) {
	kCTCallStatusAnswered = 1, //电话接通
	kCTCallStatusCallIn = 4, //有来电
	kCTCallStatusHungUp = 5 //挂断电话
};

//苹果CoreTelephony的私有API
//电话状态通知
static const CFStringRef kCTCallStatusChangeNotification = CFSTR("kCTCallStatusChangeNotification");
//找出电话号码
extern NSString *CTCallCopyAddress(void *, CTCall *call);

//CallCenter
extern CFNotificationCenterRef CTTelephonyCenterGetDefault();

//extern NSString *SBIncomingCallPendingNotification;

//创建observer
extern void CTTelephonyCenterAddObserver(CFNotificationCenterRef          center,
                                         const void *                     observer,
                                         CFNotificationCallback           callBack,
                                         CFStringRef                      name,
                                         const void *                     object,
                                         CFNotificationSuspensionBehavior suspensionBehavior);

//移除observer
extern void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef center,
                                            const void *            observer,
                                            CFStringRef             name,
                                            const void *            object);

@interface HMTManager ()
//查询请求
@property (nonatomic, strong) NSOperation *queryOperation;
@end

@implementation HMTManager

+ (instancetype)shared {
	static dispatch_once_t onceToken;
	static HMTManager *__instance;
	dispatch_once(&onceToken, ^{
	    __instance = [[HMTManager alloc] init];
	});
	return __instance;
}

//- (instancetype)init {
//  if(self = [super init]) {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCall:) name:@"SBIncomingCallPendingNotification" object:nil];
//  }
//  return self;
//}

#pragma mark - Phone observer control
//电话状态改变的callback
static void callHandler(CFNotificationCenterRef center, void *observer,
                        CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSDictionary *info = (__bridge NSDictionary *)(userInfo);
	CTCall *call = (CTCall *)info[@"kCTCall"];

	CTCallStatus status = (CTCallStatus)[info[@"kCTCallStatus"] shortValue];

	if (status == kCTCallStatusCallIn) {
		__weak HMTManager *weakManager = [HMTManager shared];
    NSString *phoneNumber = (NSString *)CTCallCopyAddress(NULL, call);
    DNSLog(@"Call in: %@", phoneNumber);
#warning 改为判断正确的号码
//[weakManager queryPhoneNumber:@"14730359182"];
	[weakManager queryPhoneNumber:phoneNumber];
	} else if (status == kCTCallStatusHungUp){
		if([HMTManager shared].queryOperation){
			[[HMTManager shared].queryOperation cancel];
			[HMTManager shared].queryOperation = nil;
		}
	}else if (status == kCTCallStatusAnswered) { //1
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); //kSystemSoundID_Vibrate系统震动
	}
}

#pragma mark - Public

//查询电话
- (void)queryPhoneNumber:(NSString *)phoneNumber {
	[self.queryOperation cancel];

	self.queryOperation = [[HMTServer sharedServer] queryNumberInfo:phoneNumber success: ^(HMTNumberInfo *result) {
	    dispatch_async(dispatch_get_main_queue(), ^{
	        self.queryOperation = nil;
	        [self notify:result number:phoneNumber];
		});
	} failure: ^(NSError *error) {
	    dispatch_async(dispatch_get_main_queue(), ^{

        [self notify:nil number:phoneNumber];

	        self.queryOperation = nil;
		});
	}];
}
#pragma mark - private

- (void)notify:(HMTNumberInfo *)numberInfo number:(NSString *)number {
	NSString *info = [NSString stringWithFormat:@"%@: %@",numberInfo.phoneNumber, numberInfo.info];
  NSLog(@"info %@",info);
 
#warning 判断一下类型
//  if(numberInfo.numberType !=kNumberTypeNormal) {
//    [HPNotificationManager  showMessage:info];
//  }
    [HPNotificationManager  showMessage:info];
  
}

#pragma mark - public
//激活监听
- (void)activate {
	CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(),
	                             NULL,
	                             &callHandler,
	                             kCTCallStatusChangeNotification,
	                             NULL,
	                             CFNotificationSuspensionBehaviorHold
	                             );
}

//取消监听
- (void)deactivate {
	CTTelephonyCenterRemoveObserver(CTTelephonyCenterGetDefault(),
	                                NULL,
	                                kCTCallStatusChangeNotification,
	                                NULL);
}

@end
