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

#import <Foundation/Foundation.h>

@interface TXARequest : NSMutableURLRequest

// Designated Initializer.
- (id)initWithURL:(NSURL *)url
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
              key:(NSString *)key
           secret:(NSString *)secret
      accessToken:(NSString *)accessToken
      tokenSecret:(NSString *)tokenSecret;

- (id)initWithURL:(NSURL *)url
              key:(NSString *)key
           secret:(NSString *)secret
      accessToken:(NSString *)accessToken
      tokenSecret:(NSString *)tokenSecret;

// Used for the request to fetch the access token.
- (id)initWithURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret;


- (void)addParam:(NSString *)name value:(NSString *)value;
- (void)addXauthParamsForUsername:(NSString *)username password:(NSString *)password;
- (void)sign;

@end
