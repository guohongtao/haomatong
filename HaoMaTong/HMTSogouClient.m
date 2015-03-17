//
//  HMTSogouClient.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HMTSogouClient.h"
#import "HMTServerConstant.h"
@implementation HMTSogouClient
+ (HMTSogouClient *)sharedClient {
  static HMTSogouClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(& onceToken, ^{
    _sharedClient = [[HMTSogouClient alloc] initWithBaseURL:[NSURL URLWithString:HMTSogouAPIBaseURLString]];
  });
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];

  if (self) {
    self.responseSerializer = [AFHTTPResponseSerializer new];
    //     self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json",nil];
  }

  return self;
}

#pragma mark - Public

- (NSOperation *)request:(NSURLRequest *)request
  success:(void (^)(AFHTTPRequestOperation *, id))success
  failure:(void (^)(NSError *, NSData *))failure {
  AFHTTPRequestOperation *operation = [self requestOperationWithRequest:request
                                                                success:success
                                                                failure:failure];
  [self.operationQueue addOperation:operation];
  return operation;
}

#pragma mark - Private
- (AFHTTPRequestOperation *)requestOperationWithRequest:(NSURLRequest *)request
  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
  failure:(void (^)(NSError *error, NSData *responseData))failure {
  void (^requestSucceededBlock)(AFHTTPRequestOperation *operation, id responseObject);
  void (^requestFailedBlock)(AFHTTPRequestOperation *operation, NSError *error);

  requestSucceededBlock = nil;
  requestFailedBlock    = nil;

  if (success) {
    requestSucceededBlock =
      ^(AFHTTPRequestOperation *operation, id responseObject) {
      /* 处理 API 返回错误 */
      //这里返回的应该是show(json) 其中show为callback函数名


      NSError *error = [self errorFromResponseObject:responseObject];

      if (error) {
        failure(error, operation.responseData);
      } else {
        success(operation, responseObject);
      }
    };
  }

  if (failure) {
    requestFailedBlock =
      ^(AFHTTPRequestOperation *operation, NSError *error) {
      [(NSData *)operation.responseData writeToFile:[self dataFileForName:@"sogouResponseData.txt"] atomically:YES];

      NSError *finalError = nil;

      /* 不能获取服务器返回错误信息时，返回 operation 的错误信息 */
      if (error.domain == AFNetworkingErrorDomain) {
        /* 将 AFNetworkingError 转换为 WPInternalNetworkingError 抛给外部，隐藏 SDK 内部使用的的 AFNetworkingError */
        finalError = [[NSError alloc] initWithDomain:HMTApiInternalNetworkingErrorDomain
                                                code:error.code
                                            userInfo:@{ NSLocalizedDescriptionKey : error.localizedDescription }];
      } else {
        finalError = error;
      }

      failure(finalError, operation.responseData);
    };
  }

  AFHTTPRequestOperation *operation =
    [self HTTPRequestOperationWithRequest:request success:requestSucceededBlock failure:requestFailedBlock];
  [operation.outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
  return operation;
}

#pragma mark - private

- (NSError *)errorFromResponseObject:(id)response {
  NSMutableData *data = [[NSMutableData alloc] initWithData:response];
  [data replaceBytesInRange:NSMakeRange(data.length - 1, 1) withBytes:""];
  [data replaceBytesInRange:NSMakeRange(0, 5) withBytes:""];

  id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

  if ([responseObject isKindOfClass:[NSDictionary class]]) {
    NSInteger errorCode = [[responseObject valueForKeyPath:HMTSogouAPIResponseMessageKeyErrorCode] integerValue];

    if (errorCode) {
      NSString *errorDescription = [responseObject valueForKeyPath:HMTSogouAPIResponseMessageKeyErrorDescription];
      NSError *error = [[NSError alloc] initWithDomain:HMTApiInternalNetworkingErrorDomain
                                                  code:errorCode
                                              userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(errorDescription, @"") }];
      return error;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (NSString *)dataFileForName:(NSString *)filename {
  NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

  return [documentFolderPath stringByAppendingPathComponent:filename];
}

@end