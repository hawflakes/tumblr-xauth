#import "TXAClient.h"

#import <Foundation/Foundation.h>

static NSString *const kTumblrAccessTokenUrl = @"https://www.tumblr.com/oauth/access_token";

@interface TXAClient () {
  NSString *_key;
  NSString *_secret;
}
@end

@implementation TXAClient

- (id)init {
  return [self initWithKey:nil secret:nil];
}

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
  self = [super init];
  if (self) {
    _key = [key copy];
    _secret = [secret copy];
  }
  return self;
}

#pragma mark - Class Extension Methods

@end
