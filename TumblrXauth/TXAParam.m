// Copyright 2013 Emanata, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "TXAParam.h"

#import <Foundation/Foundation.h>

#import "NSString+TXAURLEncoding.h"

@implementation TXAParam

#pragma mark - Initializers

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

#pragma mark - Public Methods

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

- (NSComparisonResult)compareForSignatureBaseString:(TXAParam *)other {
  NSString *encodedName1 = [self.name TXAParameterEncode];
  NSString *encodedName2 = [other.name TXAParameterEncode];
  NSComparisonResult result = [encodedName1 compare:encodedName2];
  if (result == NSOrderedSame) {
    NSString *encodedValue1 = [self.value TXAParameterEncode];
    NSString *encodedValue2 = [other.value TXAParameterEncode];
    result = [encodedValue1 compare:encodedValue2];
  }
  return result;
}

#pragma mark - NSObject Protocol Methods

- (NSUInteger)hash {
  return [_name hash] ^ [_value hash] ^ 0x5c5c5c5c;
}

- (BOOL)isEqual:(id)object {
  if (!object || ![object isMemberOfClass:[self class]]) {
    return NO;
  }
  TXAParam *other = (TXAParam *)object;
  return [self.name isEqualToString:other.name] && [self.value isEqualToString:other.value];
}

@end
