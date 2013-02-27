#import "TXARequest.h"

#import <CommonCrypto/CommonCrypto.h>
#import <Foundation/Foundation.h>

#import "NSData+TXABase64.h"
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
- (NSString *)generateSignatureBaseString;
- (NSString *)generateSignatureBaseStringParamSection;
- (NSString *)generateSignatureBaseStringURLSection;
- (NSString *)generateSignatureSecret;
- (NSString *)generateTimestamp;
@end

// TXARequest is designed for compliance with OAuth 1.0a as documented at
// http://oauth.net/core/1.0a
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

- (void)addParam:(NSString *)name value:(NSString *)value {
  [_userParams addObject:[TXAParam paramWithName:name value:value]];
}

- (void)addXauthParamsForUsername:(NSString *)username password:(NSString *)password {
  [_xauthParams removeAllObjects];
  [_xauthParams addObject:[TXAParam paramWithName:@"x_auth_mode" value:@"client_auth"]];
  [_xauthParams addObject:[TXAParam paramWithName:@"x_auth_username" value:username]];
  [_xauthParams addObject:[TXAParam paramWithName:@"x_auth_password" value:password]];
}

- (void)sign {
  _nonce = [self generateNonce];
  _timestamp = [self generateTimestamp];

  [self regenerateOauthParams];

  NSString *signatureBaseString = [self generateSignatureBaseString];
  NSString *signatureSecret = [self generateSignatureSecret];
  NSData *data = [signatureBaseString dataUsingEncoding:NSUTF8StringEncoding];
  NSData *key = [signatureSecret dataUsingEncoding:NSUTF8StringEncoding];
  NSMutableData *mac = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
  CCHmac(kCCHmacAlgSHA1, [key bytes], [key length], [data bytes], [data length], [mac mutableBytes]);
  _signature = [mac TXABase64EncodedString];

  [self regenerateOauthParams];

  [self setValue:[self generateAuthorizationHeaderValue] forHTTPHeaderField:@"Authorization"];

  NSMutableArray *params = [NSMutableArray arrayWithCapacity:[_userParams count]];
  for (TXAParam *param in _xauthParams) {
    [params addObject:[param formatForURL]];
  }
  for (TXAParam *param in _userParams) {
    [params addObject:[param formatForURL]];
  }
  NSString *urlEncodedUserParams = [params componentsJoinedByString:@"&"];
  if ([[self HTTPMethod] isEqualToString:@"POST"]) {
    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self setHTTPBody:[urlEncodedUserParams dataUsingEncoding:NSUTF8StringEncoding]];
  } else if ([urlEncodedUserParams length] > 0) {
    NSString *queryString = [NSString stringWithFormat:@"?%@", urlEncodedUserParams];
    NSURL *url = [NSURL URLWithString:queryString relativeToURL:[self URL]];
    [self setURL:url];
  }
}

#pragma mark - Class Extension Methods

- (void)regenerateOauthParams {
  [_oauthParams removeAllObjects];
  if (_key) {
    [_oauthParams addObject:[TXAParam paramWithName:@"oauth_consumer_key" value:_key]];
  }
  if (_accessToken) {
    [_oauthParams addObject:[TXAParam paramWithName:@"oauth_token" value:_accessToken]];
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
  return [NSString stringWithFormat:@"OAuth %@", [params componentsJoinedByString:@", "]];
}

- (NSString *)generateNonce {
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);
  return CFBridgingRelease(uuidString);
}

- (NSString *)generateSignatureBaseString {
  NSString *methodSection = [self HTTPMethod];
  NSString *urlSection = [self generateSignatureBaseStringURLSection];
  NSString *paramSection = [self generateSignatureBaseStringParamSection];
  NSArray *sections = @[
    [methodSection TXAParameterEncode],
    [urlSection TXAParameterEncode],
    [paramSection TXAParameterEncode]
  ];
  return [sections componentsJoinedByString:@"&"];
}

- (NSString *)generateSignatureBaseStringParamSection {
  NSMutableArray *params = [NSMutableArray array];
  for (TXAParam *param in _oauthParams) {
    if (![param.name isEqualToString:@"oauth_signature"] && ![param.name isEqualToString:@"realm"]) {
      [params addObject:param];
    }
  }
  [params addObjectsFromArray:_xauthParams];
  [params addObjectsFromArray:_userParams];
  [params sortUsingSelector:@selector(compareForSignatureBaseString:)];
  NSMutableArray *encodedParams = [NSMutableArray arrayWithCapacity:[params count]];
  for (TXAParam *param in params) {
    [encodedParams addObject:[param formatForSignatureBaseString]];
  }
  return [encodedParams componentsJoinedByString:@"&"];
}

- (NSString *)generateSignatureBaseStringURLSection {
  NSString *scheme = [[self URL] scheme];
  NSString *host = [[self URL] host];
  NSNumber *port = [[self URL] port];
  NSString *path = [[self URL] path];
  if (port && scheme &&
      ((port.unsignedIntValue == 80 && [scheme isEqualToString:@"http"]) ||
       (port.unsignedIntValue == 443 && [scheme isEqualToString:@"https"]))) {
    port = nil;
  }
  if (!path) {
    path = @"";
  }
  if (port) {
    return [NSString stringWithFormat:@"%@://%@:%@%@", scheme, host, port, path];
  } else {
    return [NSString stringWithFormat:@"%@://%@%@", scheme, host, path];
  }
}

- (NSString *)generateSignatureSecret {
  NSString *encodedSecret = [_secret TXAParameterEncode];
  NSString *encodedTokenSecret = [_tokenSecret TXAParameterEncode];
  encodedSecret = encodedSecret ? encodedSecret : @"";
  encodedTokenSecret = encodedTokenSecret ? encodedTokenSecret : @"";
  return [NSString stringWithFormat:@"%@&%@", encodedSecret, encodedTokenSecret];
}

- (NSString *)generateTimestamp {
  long epochTime = (long)[[NSDate date] timeIntervalSince1970];
  return [NSString stringWithFormat:@"%ld", epochTime];
}

@end
