#import "TXAClient.h"

#import <Foundation/Foundation.h>

#import "TXARequest.h"

static NSString *const kTumblrAccessTokenUrl = @"https://www.tumblr.com/oauth/access_token";

static NSString *const kConnInfoKeyCallback = @"callback";
static NSString *const kConnInfoKeyData = @"data";
static NSString *const kConnInfoKeyRequest = @"request";
static NSString *const kConnInfoKeyResponse = @"response";

@interface TXAClient () <NSURLConnectionDataDelegate> {
  NSString *_key;
  NSString *_secret;
  NSString *_accessToken;
  NSString *_tokenSecret;

  CFMutableDictionaryRef _connectionInfoMap;
}
- (NSMutableDictionary *)connectionInfoForConnection:(NSURLConnection *)connection;
@end

@implementation TXAClient

@synthesize key = _key;
@synthesize secret = _secret;
@synthesize accessToken = _accessToken;
@synthesize tokenSecret = _tokenSecret;

+ (TXAClient *)sharedInstanceWithKey:(NSString *)key secret:(NSString *)secret {
  static TXAClient *client;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    client = [[TXAClient alloc] initWithKey:key secret:secret];
  });
  return client;
}

- (id)init {
  return [self initWithKey:nil secret:nil];
}

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
  self = [super init];
  if (self) {
    _key = [key copy];
    _secret = [secret copy];

    // We cannot use NSMutableDictionary for this since it tries to copy its keys.
    // NSMapTable would be perfect, but it doesn't show up until iOS 6.
    _connectionInfoMap = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  }
  return self;
}

- (void)dealloc {
  CFRelease(_connectionInfoMap);
}

- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password
              completionCallback:(TXAClientSimpleCompletionCallback)completionCallback {
  NSURL *url = [NSURL URLWithString:kTumblrAccessTokenUrl];
  TXARequest *request = [[TXARequest alloc] initWithURL:url key:_key secret:_secret];
  [request addXauthParamsForUsername:username password:password];
  [request setHTTPMethod:@"POST"];
  [request sign];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
  NSMutableDictionary *connectionInfo = [NSMutableDictionary dictionary];
  TXAClientCompletionCallback callback = ^void (NSURLResponse *response, NSData *data, NSError *error) {
    if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
      completionCallback(NO);
      return;
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] == 400 || [httpResponse statusCode] == 401) {
      completionCallback(NO);
      return;
    }

    NSString *accessToken = nil;
    NSString *tokenSecret = nil;
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *components = [responseString componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
      NSArray *keyvalue = [component componentsSeparatedByString:@"="];
      if ([keyvalue count] != 2) {
        completionCallback(NO);
        return;
      }
      NSString *key = [keyvalue objectAtIndex:0];
      NSString *value = [keyvalue objectAtIndex:1];

      if ([key isEqualToString:@"oauth_token"]) {
        accessToken = value;
      } else if ([key isEqualToString:@"oauth_token_secret"]) {
        tokenSecret = value;
      }
    }

    if (accessToken) {
      _accessToken = accessToken;
    }
    if (tokenSecret) {
      _tokenSecret = tokenSecret;
    }

    completionCallback(accessToken && tokenSecret);
  };
  [connectionInfo setValue:callback forKey:kConnInfoKeyCallback];
  [connectionInfo setValue:[NSMutableData data] forKey:kConnInfoKeyData];
  [connectionInfo setValue:request forKey:kConnInfoKeyRequest];
  CFDictionaryAddValue(_connectionInfoMap, (__bridge void *)connection, (__bridge void *)connectionInfo);
  [connection start];
}

#pragma mark - NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
  CFDictionaryRemoveValue(_connectionInfoMap, (__bridge void *)connection);
  TXAClientCompletionCallback callback = [connectionInfo objectForKey:kConnInfoKeyCallback];
  if (callback) {
    NSURLResponse *response = [connectionInfo objectForKey:kConnInfoKeyResponse];
    NSData *data = [connectionInfo objectForKey:kConnInfoKeyData];
    callback(response, data, error);
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
  NSMutableData *connectionData = [connectionInfo objectForKey:kConnInfoKeyData];
  [connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
  [connectionInfo setValue:response forKey:kConnInfoKeyResponse];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSMutableDictionary *connectionInfo = [self connectionInfoForConnection:connection];
  CFDictionaryRemoveValue(_connectionInfoMap, (__bridge void *)connection);
  TXAClientCompletionCallback callback = [connectionInfo objectForKey:kConnInfoKeyCallback];
  if (callback) {
    NSURLResponse *response = [connectionInfo objectForKey:kConnInfoKeyResponse];
    NSData *data = [connectionInfo objectForKey:kConnInfoKeyData];
    callback(response, data, nil);
  }
}

#pragma mark - Class Extension Methods

- (NSMutableDictionary *)connectionInfoForConnection:(NSURLConnection *)connection {
  return (__bridge NSMutableDictionary *)CFDictionaryGetValue(_connectionInfoMap, (__bridge void *)connection);
}

@end
