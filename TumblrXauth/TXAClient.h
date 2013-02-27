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

typedef void(^TXAClientSimpleCompletionCallback)(BOOL wasSuccessful);
typedef void(^TXAClientCompletionCallback)(NSURLResponse *response, NSData *data, NSError *error);

@interface TXAClient : NSObject

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *secret;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenSecret;

// This method stores a singleton instance of the TXAClient. It assumes your app
// has a single key and secret. If you use multiple key/secret pairs, you must
// not use this method.
+ (TXAClient *)sharedInstanceWithKey:(NSString *)key secret:(NSString *)secret;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;
- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password
              completionCallback:(TXAClientSimpleCompletionCallback)completionCallback;
- (void)retrieveUserInfoWithCompletionCallback:(TXAClientCompletionCallback)completionCallback;
- (void)postPhoto:(NSString *)sourceUrl toBlog:(NSString *)name withLink:(NSString *)link caption:(NSString *)caption completionCallback:(TXAClientCompletionCallback)completionCallback;
@end
