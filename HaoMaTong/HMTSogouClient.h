//
//  HMTSogouClient.h
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface HMTSogouClient : AFHTTPRequestOperationManager
+ (HMTSogouClient *)sharedClient;
- (NSOperation *)request:(NSURLRequest*)request
                 success:(void (^)(AFHTTPRequestOperation *, id))success
                 failure:(void (^)(NSError *, NSData *))failure;
@end
