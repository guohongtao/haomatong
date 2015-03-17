//
//  HMTNumberInfo.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 4/4/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HMTNumberInfo.h"

@implementation HMTNumberInfo

- (kNumberType)numberType {
  NSString *info = self.info  ;
  if([info rangeOfString:@"骚扰"].location != NSNotFound){
    return kNumberTypeFraud;
  }else if([info rangeOfString:@"中介"].location != NSNotFound) {
    return kNumberTypeAgent;
  }else if([info rangeOfString:@"暂无标记"].location != NSNotFound){
    return kNumberTypeNormal;
  }else if([info rangeOfString:@"外卖"].location != NSNotFound){
    return kNumberTypeTakeway;
  }else if([info rangeOfString:@"推销"].location != NSNotFound){
    return kNumberTypeAdvertise;
  }else if([info rangeOfString:@"不详"].location != NSNotFound){
    return kNumberTypeNormal;
  }
  return kNumberTypeDelivery;
}

- (NSString*)description {
  return [NSString stringWithFormat:@"(%ld) : %@",(long)self.numberType, self.info];
}

@end
