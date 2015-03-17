//
//  HMTResult.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HMTLocationInfo.h"
#import "HMTServerConstant.h"

@interface HMTLocationInfo()

@property (nonatomic,copy) NSString *element;
@end
@implementation HMTLocationInfo

- (id)initWithXML:(NSXMLParser*)xmlParser
{
  self = [super init];
  if(self)
  {
    xmlParser.delegate = self;
    [xmlParser parse];    
  }
  return self;
}


- (NSString*)description
{
  return [NSString stringWithFormat:@"%@ %@\n%@",self.province,self.city,self.serviceProvider];
}

- (NSString*)displayString
{
  NSMutableString *string = [[NSMutableString alloc] init];
  if(self.province)
  {
    [string appendString:self.province];
    [string appendString:@" "];

  }

  if(self.city)
  {
    [string appendString:self.city];
    [string appendString:@" "];

  }
  
  if(self.serviceProvider)
  {
    [string appendString:self.serviceProvider];
    
  }
  return string;
}

//第一个代理方法：
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
  
}

//第二个代理方法：
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  //获取文本节点中的数据，因为下面的方法要保存这里获取的数据，所以要定义一个全局变量(可修改的字符串)
  //NSMutableString *element = [[NSMutableString alloc]init];
  //这里要赋值为空，目的是为了清空上一次的赋值
    self.element = string;
  //[self.element appendString:string];//string是获取到的文本节点的值，只要是文本节点都会获取(包括换行)，然后到下个方法中进行判断区分

}

//第三个代理方法：
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if(!self.element)
  {
    return;
  }
    
  NSString *str=[[NSString alloc] initWithString:self.element];
  
	if ([elementName isEqualToString:@"city"]) {
    self.city = str;
  }else if ([elementName isEqualToString:@"province"]) {
    self.province = str;
  }else if ([elementName isEqualToString:@"supplier"]) {
    self.serviceProvider = str;
  }
 
}

@end
