//
//  HMTResult.h
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMTLocationInfo : NSObject <NSXMLParserDelegate>

@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *serviceProvider;


- (NSString*)displayString;
- (id)initWithXML:(NSXMLParser*)xmlParser;
@end
