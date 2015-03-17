//
//  HMTNumberInfo.h
//  HaoMaTong
//
//  Created by Hongtao Guo on 4/4/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import <Foundation/Foundation.h>

//查询结果类型

typedef NS_ENUM(NSInteger, kNumberType)
{
  kNumberTypeAdvertise = 0, //推销电话
  kNumberTypeDelivery = 1, //快递
  kNumberTypeTakeway = 2, //外卖
  kNumberTypeFraud = 3, //骚扰
  kNumberTypeAgent = 4, //房产中介
  kNumberTypeNormal = 5 //其他
};


@interface HMTNumberInfo : NSObject
@property (copy, nonatomic) NSString *info;
@property (copy, nonatomic) NSString *tagAmount;
@property (copy, nonatomic) NSString *phoneNumber;
@property (nonatomic) kNumberType  numberType;
@end
