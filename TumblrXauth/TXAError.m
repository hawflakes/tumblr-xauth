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

#import "TXAError.h"

#import <Foundation/Foundation.h>

#import "TXAUtils.h"

NSString *const kTXAErrorDomain = @"TumblrXauth.Error";

@implementation TXAError

- (id)initWithCode:(TXAErrorCode)code {
  return [self initWithDomain:kTXAErrorDomain code:code userInfo:nil];
}

- (id)initWithCode:(TXAErrorCode)code userInfo:(NSDictionary *)userInfo {
  return [self initWithDomain:kTXAErrorDomain code:code userInfo:userInfo];
}

+ (TXAError *)errorWithCode:(TXAErrorCode)code {
  return [[TXAError alloc] initWithCode:code];
}

+ (TXAError *)errorWithCode:(TXAErrorCode)code userInfo:(NSDictionary *)userInfo {
  return [[TXAError alloc] initWithCode:code userInfo:userInfo];
}

- (NSString *)localizedDescription {
  switch ([self code]) {
    case kTXAErrorCodeAuthFailure:
      return NSLocalizedStringFromTableInBundle(@"Insufficient permissions to perform the requested action given the current access token", @"Errors", TXAFrameworkBundle(), @"Error description");
    case kTXAErrorCodeBadStatusCode:
      return NSLocalizedStringFromTableInBundle(@"Status code returned from the server did not match expectations for the requested action", @"Errors", TXAFrameworkBundle(), @"Error description");
    case kTXAErrorCodeNonHttpResponse:
      return NSLocalizedStringFromTableInBundle(@"Response type was not HTTP", @"Errors", TXAFrameworkBundle(), @"Error description");
    default:
      return [super localizedDescription];
  }
}

@end
