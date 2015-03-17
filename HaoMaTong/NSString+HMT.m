//
//  NSString+HMT.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "NSString+HMT.h"

@implementation NSString (HMT)

- (NSString *)URLEncode
{
  CFStringRef url = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return (__bridge NSString *)url;
}

- (NSString *)removeHTML
{
  
  NSScanner *theScanner;
  
  NSString *text = nil;
  NSString *html = self;
  
  
  theScanner = [NSScanner scannerWithString:self];
  
  
  
  while ([theScanner isAtEnd] == NO) {
    
    // find start of tag
    
    [theScanner scanUpToString:@"<" intoString:NULL] ;
    
    
    
    // find end of tag
    
    [theScanner scanUpToString:@">" intoString:&text] ;
    
    
    
    // replace the found tag with a space
    
    //(you can filter multi-spaces out later if you wish)
    
    html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
    
    
    
  }
  
  return html;
  
}

- (BOOL)isMobile
{
  if(self.length != 11) return NO;
  
  NSString *sub = [self substringWithRange:NSMakeRange(0, 3)];
  NSString *path = [[NSBundle mainBundle] pathForResource:@"MobilePhone" ofType:@"plist"];

  NSArray *phoneArray = [[NSArray alloc] initWithContentsOfFile:path];
  
  if([phoneArray indexOfObject:sub]!= NSNotFound)
  {
    return YES;
  }else
    return NO;
}

@end
