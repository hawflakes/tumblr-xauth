#import "NSString+TXAURLEncoding.h"

#import <Foundation/Foundation.h>

@implementation NSString (TXAURLEncoding)

- (NSString *)TXAParameterEncode {
  return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
      NULL, (__bridge CFStringRef)self, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
}

- (NSString *)TXAParameterDecode {
  return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(
      NULL, (__bridge CFStringRef)self, CFSTR(""));
}

@end
