#import "TXARequest.h"

#import <Foundation/Foundation.h>

@interface TXARequest () {
  NSString *_key;
  NSString *_secret;
  NSString *_accessToken;
  NSString *_tokenSecret;
}
+ (NSString *)generateNonce;
+ (NSString *)generateTimestamp;
@end

@implementation TXARequest

- (id)initWithURL:(NSURL *)url
              key:(NSString *)key
           secret:(NSString *)secret
      accessToken:(NSString *)accessToken
      tokenSecret:(NSString *)tokenSecret {
  self = [super initWithURL:url];
  if (self) {
    _key = [key copy];
    _secret = [secret copy];
    _accessToken = [accessToken copy];
    _tokenSecret = [tokenSecret copy];
  }
  return self;
}

- (id)initWithURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
  return [self initWithURL:url
                       key:key
                    secret:secret
               accessToken:nil
               tokenSecret:nil];
}

#pragma mark - Class Extension Methods

+ (NSString *)generateNonce {
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
  CFRelease(uuid);
  return CFBridgingRelease(uuidString);
}

+ (NSString *)generateTimestamp {
  long epochTime = (long)[[NSDate date] timeIntervalSince1970];
  return [NSString stringWithFormat:@"%ld", epochTime];
}

@end
