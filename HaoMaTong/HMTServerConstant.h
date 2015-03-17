//
//  HMTServerConstant.h
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#ifndef HaoMaTong_HMTServerConstant_h
#define HaoMaTong_HMTServerConstant_h


static NSString *const HMTApiRequestBondary = @"_________________12341234123412341234SAFARIBOUNDARY";


#pragma mark - 财富通 API
//http://life.tenpay.com/cgi-bin/mobile/MobileQueryAttribution.cgi?chgmobile=15850781443

static NSString *const HMTCaiFuTongURLString = @"http://life.tenpay.com/cgi-bin/mobile/";
static NSString *const HMTCaiFuTongApiQueryKeySerach = @"MobileQueryAttribution.cgi";
static NSString *const HMTCaiFuTongQueryKeyMobile = @"chgmobile";

static NSString *const HMTCaiFuTongResponseKeyProvince = @"province";
static NSString *const HMTCaiFuTongResponseKeyCity = @"city";
static NSString *const HMTCaiFuTongResponseKeyServiceProvider = @"isp";

#pragma mark -搜狗API
//http://data.haoma.sogou.com/vrapi/query_number.php?number=14730359182&type=json&callback=show
//show({"NumInfo":"\u8be5\u53f7\u7801\u6682\u65e0\u6807\u8bb0","errorCode":0})
//要去掉show(和);

static NSString *const HMTSogouAPIBaseURLString = @"http://data.haoma.sogou.com/vrapi/";
static NSString *const HMTSogouAPISearch = @"query_number.php";
static NSString *const HMTSogouAPIQueryKeyNumber = @"number";
static NSString *const HMTSogouAPIQueryKeyType = @"type";
static NSString *const HMTSogouAPIQueryKeyCallback = @"callback";

static NSString *const HMTSogouAPIResponseMessageKeyErrorCode = @"errorCode";
static NSString *const HMTSogouAPIResponseMessageKeyErrorDescription = @"description";
static NSString *const HMTSogouAPIResponseMessageKeyNumberInfo = @"NumInfo";
static NSString *const HMTSogouAPIResponseMessageKeyTagAmount = @"Amount";


static NSString *const HMTApiInternalNetworkingErrorDomain = @"HMT Internal Error";

#endif
