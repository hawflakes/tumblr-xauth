#import "TXAClient.h"

#import <Foundation/Foundation.h>

static NSString *const kTumblrAccessTokenUrl = @"https://www.tumblr.com/oauth/access_token";

@interface TXAClient () {
  NSString *_key;
  NSString *_secret;
}
+ (NSString *)generateNonce;
+ (NSString *)generateTimestamp;
@end

@implementation TXAClient

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
  self = [super init];
  if (self) {
    _key = [key copy];
    _secret = [secret copy];
  }
  return self;
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
