#import <Foundation/Foundation.h>

typedef void(^TXAClientSimpleCompletionCallback)(BOOL wasSuccessful);
typedef void(^TXAClientCompletionCallback)(NSURLResponse *response, NSData *data, NSError *error);

@interface TXAClient : NSObject
- (id)initWithKey:(NSString *)key secret:(NSString *)secret;
- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password
              completionCallback:(TXAClientSimpleCompletionCallback)completionCallback;
@end
