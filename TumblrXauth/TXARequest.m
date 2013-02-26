#import "TXARequest.h"

#import <Foundation/Foundation.h>

#import "NSString+TXAURLEncoding.h"
#import "TXAParam.h"

@interface TXARequest () {
  NSString *_key;
  NSString *_secret;
  NSString *_accessToken;
  NSString *_tokenSecret;
  NSString *_nonce;
  NSString *_timestamp;
  NSString *_signature;

  NSMutableArray *_oauthParams;
  NSMutableArray *_xauthParams;
  NSMutableArray *_userParams;
}
- (void)regenerateOauthParams;
- (NSString *)generateAuthorizationHeaderValue;
- (NSString *)generateNonce;
- (NSString *)generateTimestamp;
@end

@implementation TXARequest

#pragma mark - Initializers

- (id)initWithURL:(NSURL *)url
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval {
  return [self initWithURL:url
               cachePolicy:cachePolicy
           timeoutInterval:timeoutInterval
                       key:nil
                    secret:nil
               accessToken:nil
               tokenSecret:nil];
}

- (id)initWithURL:(NSURL *)url
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
  timeoutInterval:(NSTimeInterval)timeoutInterval
              key:(NSString *)key
           secret:(NSString *)secret
      accessToken:(NSString *)accessToken
      tokenSecret:(NSString *)tokenSecret {
  self = [super initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
  if (self) {
    _key = [key copy];
    _secret = [secret copy];
    _accessToken = [accessToken copy];
    _tokenSecret = [tokenSecret copy];

    _oauthParams = [NSMutableArray array];
    _xauthParams = [NSMutableArray array];
    _userParams = [NSMutableArray array];

    [self regenerateOauthParams];
  }
  return self;
}

- (id)initWithURL:(NSURL *)url
              key:(NSString *)key
           secret:(NSString *)secret
      accessToken:(NSString *)accessToken
      tokenSecret:(NSString *)tokenSecret {
  return [self initWithURL:url
               cachePolicy:NSURLRequestUseProtocolCachePolicy
           timeoutInterval:60
                       key:key
                    secret:secret
               accessToken:accessToken
               tokenSecret:tokenSecret];
}

- (id)initWithURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
  return [self initWithURL:url
                       key:key
                    secret:secret
               accessToken:nil
               tokenSecret:nil];
}

#pragma mark - Public Methods

- (void)addXauthParamsForUsername:(NSString *)username password:(NSString *)password {
  [_xauthParams removeAllObjects];
  [_xauthParams addObject:[TXAParam paramWithName:@"x_auth_mode" value:@"client_auth"]];
  [_xauthParams addObject:[TXAParam paramWithName:@"x_auth_username" value:username]];
  [_xauthParams addObject:[TXAParam paramWithName:@"x_auth_password" value:password]];
}

- (void)sign {
  _nonce = [self generateNonce];
  _timestamp = [self generateTimestamp];
  // TODO: fill in signature
  [self regenerateOauthParams];
}

#pragma mark - Class Extension Methods

- (void)regenerateOauthParams {
  [_oauthParams removeAllObjects];
  if (_key) {
    [_oauthParams addObject:[TXAParam paramWithName:@"oauth_consumer_key" value:_key]];
  }
  [_oauthParams addObject:[TXAParam paramWithName:@"oauth_signature_method" value:@"HMAC-SHA1"]];
  if (_signature) {
    [_oauthParams addObject:[TXAParam paramWithName:@"oauth_signature" value:_signature]];
  }
  if (_timestamp) {
    [_oauthParams addObject:[TXAParam paramWithName:@"oauth_timestamp" value:_timestamp]];
  }
  if (_nonce) {
    [_oauthParams addObject:[TXAParam paramWithName:@"oauth_nonce" value:_nonce]];
  }
  [_oauthParams addObject:[TXAParam paramWithName:@"oauth_version" value:@"1.0"]];
}

- (NSString *)generateAuthorizationHeaderValue {
  NSMutableArray *params = [[NSMutableArray alloc] init];
  for (TXAParam *param in _oauthParams) {
    [params addObject:[param formatForAuthorizationHeader]];
  }
  for (TXAParam *param in _xauthParams) {
    [params addObject:[param formatForAuthorizationHeader]];
  }
  return [NSString stringWithFormat:@"OAuth %@", [params componentsJoinedByString:@", "]];
}

- (NSString *)generateNonce {
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);
  return CFBridgingRelease(uuidString);
}

- (NSString *)generateTimestamp {
  long epochTime = (long)[[NSDate date] timeIntervalSince1970];
  return [NSString stringWithFormat:@"%ld", epochTime];
}

@end
