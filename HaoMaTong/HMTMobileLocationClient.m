//
//  HMTServerClient.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HMTMobileLocationClient.h"

@implementation HMTMobileLocationClient

+ (HMTMobileLocationClient *)sharedClient
{
  static HMTMobileLocationClient *_sharedClient = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedClient = [[HMTMobileLocationClient alloc] initWithBaseURL:[NSURL URLWithString:HMTCaiFuTongURLString]];
  });
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
  self = [super initWithBaseURL:url];
  if (self) {
    
    self.responseSerializer = [AFXMLParserResponseSerializer new];
//    //淘宝返回来的josn content-type是application/javascript
//    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json",nil];
//    
  }
  return self;
}

#pragma mark - Public

- (NSOperation *)request:(NSURLRequest*)request
                 success:(void (^)(AFHTTPRequestOperation *, id))success
                 failure:(void (^)(NSError *, NSData *))failure
{
  
  AFHTTPRequestOperation *operation = [self requestOperationWithRequest:request
                                                                success:success
                                                                failure:failure];
  [self.operationQueue addOperation:operation];
  return operation;
}

#pragma mark - Private
- (AFHTTPRequestOperation *)requestOperationWithRequest:(NSURLRequest *)request
                                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                failure:(void (^)(NSError *error, NSData *responseData))failure
{

  void (^requestSucceededBlock)(AFHTTPRequestOperation *operation, id responseObject);
  void (^requestFailedBlock)(AFHTTPRequestOperation *operation, NSError *error);
  
  requestSucceededBlock = nil;
  requestFailedBlock    = nil;
  
  if(success){
    requestSucceededBlock =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
      success(operation,responseObject);
      
    };
  }
  
  if(failure){
    requestFailedBlock =
    ^(AFHTTPRequestOperation *operation, NSError *error) {
      
      NSError *finalError = nil;
     
      /* 不能获取服务器返回错误信息时，返回 operation 的错误信息 */
      if(error.domain == AFNetworkingErrorDomain)
      {
        
        /* 将 AFNetworkingError 转换为 WPInternalNetworkingError 抛给外部，隐藏 SDK 内部使用的的 AFNetworkingError */
        finalError = [[NSError alloc] initWithDomain:HMTApiInternalNetworkingErrorDomain
                                                code:error.code
                                            userInfo:@{ NSLocalizedDescriptionKey : error.localizedDescription }];
      }else {
        finalError = error;
      }

      failure(finalError,operation.responseData);
      
    };
  }
  
  AFHTTPRequestOperation *operation =
  [self HTTPRequestOperationWithRequest:request success:requestSucceededBlock failure:requestFailedBlock];
  return operation;
}

- (NSString*)dataFileForName:(NSString*)filename
{
  NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	
	return [documentFolderPath stringByAppendingPathComponent:filename];
}
@end
