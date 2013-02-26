#import <Foundation/Foundation.h>

@interface TXARequest : NSMutableURLRequest

// Designated Initializer.
//
// It is assumed that this request will be used shortly after initialization.
// Holding it for a long period of time before submitting the request to the
// server may result in rejection of the request due to timestamp expiration.
- (id)initWithURL:(NSURL *)url
              key:(NSString *)key
           secret:(NSString *)secret
      accessToken:(NSString *)accessToken
      tokenSecret:(NSString *)tokenSecret;

// Used for the request to fetch the access token.
- (id)initWithURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret;

@end
