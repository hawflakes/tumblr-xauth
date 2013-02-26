#import "TXAParam.h"

#import <Foundation/Foundation.h>

#import "NSString+TXAURLEncoding.h"

@implementation TXAParam

- (id)init {
  return [self initWithName:nil value:nil];
}

- (id)initWithName:(NSString *)name value:(NSString *)value {
  self = [super init];
  if (self) {
    _name = name;
    _value = value;
  }
  return self;
}

+ (TXAParam *)paramWithName:(NSString *)name value:(NSString *)value {
  return [[TXAParam alloc] initWithName:name value:value];
}

- (NSString *)formatForAuthorizationHeader {
  return [NSString stringWithFormat:@"%@=\"%@\"", [_name TXAParameterEncode], [_value TXAParameterEncode]];
}

- (NSString *)formatForSignatureBaseString {
  return [NSString stringWithFormat:@"%@=%@", [_name TXAParameterEncode], [_value TXAParameterEncode]];
}

- (NSString *)formatForURL {
  return [NSString stringWithFormat:@"%@=%@", [_name TXAURLEncode], [_value TXAURLEncode]];
}

@end
