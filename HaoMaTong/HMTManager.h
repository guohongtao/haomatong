//
//  HMTManager.h
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import<Foundation/Foundation.h>

@interface HMTManager : NSObject

+ (HMTManager *)shared;

- (void)queryPhoneNumber:(NSString*)number;
- (void)activate;
- (void)deactivate;
@end
