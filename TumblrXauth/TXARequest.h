#import <Foundation/Foundation.h>

@interface TXARequest : NSMutableURLRequest

// Designated Initializer.
- (id)initWithURL:(NSURL *)url
              key:(NSString *)key
           secret:(NSString *)secret
      accessToken:(NSString *)accessToken
      tokenSecret:(NSString *)tokenSecret;

// Used for the request to fetch the access token.
- (id)initWithURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret;

@end
