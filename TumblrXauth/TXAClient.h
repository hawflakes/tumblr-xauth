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
