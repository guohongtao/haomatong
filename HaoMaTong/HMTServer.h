//
//  HMTServer.h
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMTLocationInfo;
@class HMTNumberInfo;

@interface HMTServer : NSObject
+ (instancetype)sharedServer;
- (id)init;
- (NSOperation *)queryNumberLocation:(NSString*)number
                     success:(void (^)(HMTLocationInfo* result))success
                     failure:(void (^)(NSError *error))failure;
- (NSOperation *)queryNumberInfo:(NSString*)number
                     success:(void (^)(HMTNumberInfo* result))success
                     failure:(void (^)(NSError *error))failure;
@end
