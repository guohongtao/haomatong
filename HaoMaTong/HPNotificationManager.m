//
//  HPNotificationManager.m
//  HaoMaTong
//
//  Created by HongTao Guo on 15/2/27.
//  Copyright (c) 2015年 guohongtao. All rights reserved.
//

#import "HPNotificationManager.h"
#import <objc/runtime.h>
#import <CoreFoundation/CoreFoundation.h>
CF_IMPLICIT_BRIDGING_ENABLED
CF_EXTERN_C_BEGIN

typedef struct __CFUserNotification * CFUserNotificationRef;

typedef void (*CFUserNotificationCallBack)(CFUserNotificationRef userNotification, CFOptionFlags responseFlags);
CF_EXPORT
CFTypeID CFUserNotificationGetTypeID(void);

CF_EXPORT
CFUserNotificationRef CFUserNotificationCreate(CFAllocatorRef allocator, CFTimeInterval timeout, CFOptionFlags flags, SInt32 *error, CFDictionaryRef dictionary);

CF_EXPORT
SInt32 CFUserNotificationReceiveResponse(CFUserNotificationRef userNotification, CFTimeInterval timeout, CFOptionFlags *responseFlags);

CF_EXPORT
CFStringRef CFUserNotificationGetResponseValue(CFUserNotificationRef userNotification, CFStringRef key, CFIndex idx);

CF_EXPORT
CFDictionaryRef CFUserNotificationGetResponseDictionary(CFUserNotificationRef userNotification);

CF_EXPORT
SInt32 CFUserNotificationUpdate(CFUserNotificationRef userNotification, CFTimeInterval timeout, CFOptionFlags flags, CFDictionaryRef dictionary);

CF_EXPORT
SInt32 CFUserNotificationCancel(CFUserNotificationRef userNotification);

CF_EXPORT
CFRunLoopSourceRef CFUserNotificationCreateRunLoopSource(CFAllocatorRef allocator, CFUserNotificationRef userNotification, CFUserNotificationCallBack callout, CFIndex order);

/* Convenience functions for handling the simplest and most common cases:
 a one-way notification, and a notification with up to three buttons. */

CF_EXPORT
SInt32 CFUserNotificationDisplayNotice(CFTimeInterval timeout, CFOptionFlags flags, CFURLRef iconURL, CFURLRef soundURL, CFURLRef localizationURL, CFStringRef alertHeader, CFStringRef alertMessage, CFStringRef defaultButtonTitle);

CF_EXPORT
SInt32 CFUserNotificationDisplayAlert(CFTimeInterval timeout, CFOptionFlags flags, CFURLRef iconURL, CFURLRef soundURL, CFURLRef localizationURL, CFStringRef alertHeader, CFStringRef alertMessage, CFStringRef defaultButtonTitle, CFStringRef alternateButtonTitle, CFStringRef otherButtonTitle, CFOptionFlags *responseFlags);

/* Flags */

enum {
  kCFUserNotificationStopAlertLevel = 0,
  kCFUserNotificationNoteAlertLevel = 1,
  kCFUserNotificationCautionAlertLevel = 2,
  kCFUserNotificationPlainAlertLevel= 3
};

enum {
  kCFUserNotificationDefaultResponse= 0,
  kCFUserNotificationAlternateResponse= 1,
  kCFUserNotificationOtherResponse= 2,
  kCFUserNotificationCancelResponse= 3
};

enum {
  kCFUserNotificationNoDefaultButtonFlag = (1UL << 5),
  kCFUserNotificationUseRadioButtonsFlag = (1UL << 6)
};



CF_INLINE CFOptionFlags CFUserNotificationCheckBoxChecked(CFIndex i) {return ((CFOptionFlags)(1UL << (8 + i)));}

CF_INLINE CFOptionFlags CFUserNotificationSecureTextField(CFIndex i) {return ((CFOptionFlags)(1UL << (16 + i)));}

CF_INLINE CFOptionFlags CFUserNotificationPopUpSelection(CFIndex n) {return ((CFOptionFlags)(n << 24));}

/* Keys */

CF_EXPORT
const CFStringRef kCFUserNotificationIconURLKey;

CF_EXPORT
const CFStringRef kCFUserNotificationSoundURLKey;

CF_EXPORT
const CFStringRef kCFUserNotificationLocalizationURLKey;

CF_EXPORT
const CFStringRef kCFUserNotificationAlertHeaderKey;

CF_EXPORT
const CFStringRef kCFUserNotificationAlertMessageKey;

CF_EXPORT
const CFStringRef kCFUserNotificationDefaultButtonTitleKey;

CF_EXPORT
const CFStringRef kCFUserNotificationAlternateButtonTitleKey;

CF_EXPORT
const CFStringRef kCFUserNotificationOtherButtonTitleKey;

CF_EXPORT
const CFStringRef kCFUserNotificationProgressIndicatorValueKey;

CF_EXPORT
const CFStringRef kCFUserNotificationPopUpTitlesKey;

CF_EXPORT
const CFStringRef kCFUserNotificationTextFieldTitlesKey;

CF_EXPORT
const CFStringRef kCFUserNotificationCheckBoxTitlesKey;

CF_EXPORT
const CFStringRef kCFUserNotificationTextFieldValuesKey;

CF_EXPORT
const CFStringRef kCFUserNotificationPopUpSelectionKey CF_AVAILABLE(10_3, NA);

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
CF_EXPORT
const CFStringRef kCFUserNotificationAlertTopMostKey;


const NSString* SBUserNotificationDismissOnLock = @"DismissOnLock";

CF_EXPORT
const CFStringRef kCFUserNotificationKeyboardTypesKey;
#endif

CF_EXTERN_C_END
CF_IMPLICIT_BRIDGING_DISABLED

CFUserNotificationRef _userNotification;
CFRunLoopSourceRef _runLoopSource;

static void callback(CFUserNotificationRef alert, CFOptionFlags responseFlags){

  CFRunLoopRemoveSource(CFRunLoopGetMain(), _runLoopSource, kCFRunLoopCommonModes);
  CFRelease(_runLoopSource);
  CFRelease(_userNotification);
}


@implementation HPNotificationManager

+ (instancetype)sharedManager {
    static HPNotificationManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HPNotificationManager alloc] init];
    });
    
    return _sharedManager;
}

+ (void)showMessage:(NSString*)message {
  CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  CFDictionaryAddValue( dict, kCFUserNotificationAlertHeaderKey, CFSTR("号码查询结果"));
  CFDictionaryAddValue( dict, kCFUserNotificationAlertMessageKey, ( __bridge CFStringRef )message);
  CFDictionaryAddValue( dict, kCFUserNotificationDefaultButtonTitleKey, CFSTR("关闭"));
  CFDictionaryAddValue( dict, kCFUserNotificationAlertTopMostKey, kCFBooleanTrue);

//Setup notification
  SInt32 err = 0;
  _userNotification = CFUserNotificationCreate(NULL, 0.0, kCFUserNotificationPlainAlertLevel, &err, dict);
  _runLoopSource = CFUserNotificationCreateRunLoopSource(NULL, _userNotification, callback, 0);
  CFRunLoopAddSource(CFRunLoopGetMain(), _runLoopSource, kCFRunLoopCommonModes);
  CFRelease(dict);

}


@end
