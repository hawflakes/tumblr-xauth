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

#import "NSError+TXAError.h"

#import <Foundation/Foundation.h>

#import "TXAError.h"

@implementation NSError (TXAError)

- (BOOL)isTXAError {
  return [self isKindOfClass:[TXAError class]] || [[self domain] isEqualToString:kTXAErrorDomain];
}

- (BOOL)isTXAErrorWithCode:(TXAErrorCode)code {
  return [self isTXAError] && [self code] == code;
}

@end
