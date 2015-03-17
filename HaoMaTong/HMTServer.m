//
//  HMTServer.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HMTServer.h"
#import "HMTServerConstant.h"
#import "NSString+HMT.h"
#import "HMTMobileLocationClient.h"
#import "HMTLocationInfo.h"
#import "HMTSogouClient.h"
#import "HMTNumberInfo.h"

@interface HMTServer ()

@property (copy, nonatomic) NSString *infoURL;
@property (copy, nonatomic) NSString *locationURL;
@property (strong, nonatomic) NSArray *mobileArray;
@property (strong, nonatomic) NSDictionary *lineDictionary;
@property (strong, nonatomic) NSDictionary *serviceNumberDictionary;

@end

@implementation HMTServer

+ (instancetype)sharedServer {
  static HMTServer *sharedInstance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(& onceToken, ^{
    sharedInstance = [[HMTServer alloc] init];
  });
  return sharedInstance;
}

- (id)init {
  self = [super init];

  if (self) {
    self.infoURL = HMTSogouAPIBaseURLString;
    self.locationURL = HMTCaiFuTongURLString;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MobilePhone" ofType:@"plist"];

    self.mobileArray = [[NSArray alloc] initWithContentsOfFile:path];

    NSString *linePath = [[NSBundle mainBundle] pathForResource:@"linePhone" ofType:@"plist"];
    self.lineDictionary = [[NSDictionary alloc] initWithContentsOfFile:linePath];

    NSString *serviceNumberPath = [[NSBundle mainBundle] pathForResource:@"ServiceNumber" ofType:@"plist"];
    self.serviceNumberDictionary = [[NSDictionary alloc] initWithContentsOfFile:serviceNumberPath];
  }

  return self;
}

#pragma mark - Public
- (NSOperation *)queryNumberLocation:(NSString *)number
  success:(void (^)(HMTLocationInfo *result))success
  failure:(void (^)(NSError *error))failure {
  HMTLocationInfo *info = [self lineInfo:number];

  if (info) {
    success(info);
    return nil;
  }

  if (![self isMobilePhone:number]) {
    failure(nil);
    return nil;
  }

  NSDictionary *parameters = @{ HMTCaiFuTongQueryKeyMobile : number };

  NSURLRequest *request = [self baseURL:self.locationURL
                               queryAPI:HMTCaiFuTongApiQueryKeySerach
                                 method:@"GET"
                             parameters:parameters];

  if (!request) {
    failure(nil);
    return nil;
  }

  return [[HMTMobileLocationClient sharedClient] request:request
                                                 success: ^(AFHTTPRequestOperation *operation, id responseObject) {
    HMTLocationInfo *result = [[HMTLocationInfo alloc] initWithXML:responseObject];

    if (result.province || result.serviceProvider) {
      success(result);
    } else {
      NSLog(@"fail");
      failure(nil);
    }
  } failure: ^(NSError *error, NSData *responseData) {
    failure(error);
  }];
}

- (NSOperation *)queryNumberInfo:(NSString *)number
  success:(void (^)(HMTNumberInfo *result))success
  failure:(void (^)(NSError *error))failure {
  if (!number.length) {
    failure(nil);
    return nil;
  }

  NSDictionary *parameters = @{ HMTSogouAPIQueryKeyCallback : @"show",
                                HMTSogouAPIQueryKeyNumber : number,
                                HMTSogouAPIQueryKeyType : @"json" };

  NSURLRequest *request = [self baseURL:self.infoURL
                               queryAPI:HMTSogouAPISearch
                                 method:@"GET"
                             parameters:parameters];

  if (!request) {
    failure(nil);
    return nil;
  }

  return [[HMTSogouClient sharedClient] request:request success: ^(AFHTTPRequestOperation *operation, id responseObject) {
    HMTNumberInfo *result = [self numberInfoFromData:responseObject];
    result.phoneNumber = number;

    if (result.info) {
      success(result);
    } else {
      NSLog(@"fail");
      failure(nil);
    }
  } failure: ^(NSError *error, NSData *responseData) {
    failure(error);
  }];
}

#pragma mark - private

- (NSURLRequest *)baseURL:(NSString *)baseURL
  queryAPI:(NSString *)api
  method:(NSString *)method
  parameters:(NSDictionary *)parameters {
  NSString *requestURL = [NSString stringWithFormat:@"%@%@", baseURL, api];

  if ([method isEqualToString:@"GET"]) {
    return [self baseURL:baseURL requestGET:requestURL parameters:parameters];
  } else if ([method isEqualToString:@"POST"])   {
    return [self baseURL:baseURL requestPOST:requestURL parameters:parameters];
  }

  return nil;
}

- (NSURLRequest *)baseURL:(NSString *)baseURL
  requestPOST:(NSString *)address
  parameters:(NSDictionary *)parameters {
  NSURL *requestURL = [[NSURL alloc] initWithString:address];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];   // cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0f];

  [request setHTTPMethod:@"POST"];
  [request setHTTPShouldHandleCookies:YES];

  NSString *boundary = HMTApiRequestBondary;

  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

  NSMutableData *body = [NSMutableData dataWithLength:0];

  for (NSString *key in parameters.allKeys) {
    id obj = parameters[key];

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    NSData *data = nil;

    if ([obj isKindOfClass:[NSData class]]) {
      //    [body appendData:[@"Content-Type: image/jpg\r\n" dataUsingEncoding : NSUTF8StringEncoding]];
      data = (NSData *)obj;
      [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"comment_att.jpg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:data];
      [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([obj isKindOfClass:[NSString class]])   {
      data = [[NSString stringWithFormat:@"%@\r\n", (NSString *)obj]dataUsingEncoding:NSUTF8StringEncoding];
      [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:data];
    }
  }

  [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

  [request setValue:@(body.length).stringValue forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/534.51.22 (KHTML, like Gecko) Version/5.1.1 Safari/534.51.22" forHTTPHeaderField:@"User-Agent"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
  [request setValue:baseURL forHTTPHeaderField:@"Referer"];
  [request setValue:@"300" forHTTPHeaderField:@"Keep-Alive"];
  request.networkServiceType = NSURLNetworkServiceTypeVoIP;

  request.HTTPBody = body;

  return request;
}

- (NSURLRequest *)baseURL:(NSString *)baseURL
  requestGET:(NSString *)address
  parameters:(NSDictionary *)parameters {
  NSURL *requestURL = nil;
  NSMutableString *urlString = nil;

  if (parameters.count > 0) {
    NSMutableArray *paramPairs = [NSMutableArray arrayWithCapacity:parameters.count];

    for (NSString *key in parameters) {
      NSString *paramPair = [NSString stringWithFormat:@"%@=%@", [key URLEncode], [parameters[key] URLEncode]];
      [paramPairs addObject:paramPair];
    }

    urlString = [[NSMutableString alloc] initWithFormat:@"%@?%@", address, [paramPairs componentsJoinedByString:@"&"]];
  } else {
    urlString = [[NSMutableString alloc] initWithString:address];
  }


  requestURL = [[NSURL alloc] initWithString:urlString];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
  [request setHTTPMethod:@"GET"];
  [request setHTTPShouldHandleCookies:YES];

  [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/534.51.22 (KHTML, like Gecko) Version/5.1.1 Safari/534.51.22" forHTTPHeaderField:@"User-Agent"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
  [request setValue:baseURL forHTTPHeaderField:@"Referer"];
  [request setValue:@"300" forHTTPHeaderField:@"Keep-Alive"];
  request.networkServiceType = NSURLNetworkServiceTypeVoIP;


  return request;
}

- (HMTNumberInfo *)numberInfoFromData:(NSData *)response {
  NSMutableString *mutableString = [[NSMutableString alloc] initWithData:response encoding:NSUTF8StringEncoding];

  [mutableString replaceCharactersInRange:NSMakeRange(0, 5) withString:@""];
  [mutableString replaceCharactersInRange:NSMakeRange(mutableString.length - 1, 1) withString:@""];

  NSData *data = [mutableString dataUsingEncoding:NSUTF8StringEncoding];

  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
  HMTNumberInfo *numberInfo = [[HMTNumberInfo alloc] init];
  NSLog(@"%@", json[HMTSogouAPIResponseMessageKeyNumberInfo]);
  numberInfo.info = [json[HMTSogouAPIResponseMessageKeyNumberInfo] stringByReplacingOccurrencesOfString:@"号码通用户数据：" withString:@""];
  numberInfo.tagAmount = json[HMTSogouAPIResponseMessageKeyTagAmount];

  return numberInfo;
}

- (BOOL)isMobilePhone:(NSString *)phoneNumber;
{
  if (phoneNumber.length != 11) {
    return NO;
  }

  NSString *sub = [phoneNumber substringWithRange:NSMakeRange(0, 3)];

  if ([self.mobileArray indexOfObject:sub] != NSNotFound) {
    return YES;
  } else {
    return NO;
  }
}

- (HMTLocationInfo *)lineInfo:(NSString *)phoneNumber {
  if (phoneNumber.length > 5) {
    NSString *three = [phoneNumber substringWithRange:NSMakeRange(0, 3)];
    NSString *five = [phoneNumber substringWithRange:NSMakeRange(0, 5)];
    NSString *four = [phoneNumber substringWithRange:NSMakeRange(0, 4)];

    if ([self.lineDictionary objectForKey:three]) {
      HMTLocationInfo *info = [[HMTLocationInfo alloc] init];
      info.province = [self.lineDictionary objectForKey:three];
      info.serviceProvider = @"固定电话";
      return info;
    } else if ([self.lineDictionary objectForKey:four])   {
      HMTLocationInfo *info = [[HMTLocationInfo alloc] init];
      info.province = [self.lineDictionary objectForKey:four];
      info.serviceProvider = @"固定电话";
      return info;
    } else if ([self.lineDictionary objectForKey:five])   {
      HMTLocationInfo *info = [[HMTLocationInfo alloc] init];
      info.province = [self.lineDictionary objectForKey:five];
      info.serviceProvider = @"固定电话";
      return info;
    }
  }

  if ([self.serviceNumberDictionary objectForKey:phoneNumber]) {
    HMTLocationInfo *info = [[HMTLocationInfo alloc] init];
    info.serviceProvider = [self.serviceNumberDictionary objectForKey:phoneNumber];
    return info;
  }

  return nil;
}

@end