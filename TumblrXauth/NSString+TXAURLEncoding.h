#import <Foundation/Foundation.h>

@interface NSString (TXAURLEncoding)
- (NSString *)TXAParameterEncode;
- (NSString *)TXAParameterDecode;
- (NSString *)TXAURLEncode;
@end
