#import <Foundation/Foundation.h>

@interface TXAParam : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;

// Designated Initializer.
- (id)initWithName:(NSString *)name value:(NSString *)value;

+ (TXAParam *)paramWithName:(NSString *)name value:(NSString *)value;

- (NSString *)formatForAuthorizationHeader;
- (NSString *)formatForSignatureBaseString;
- (NSString *)formatForURL;

- (NSComparisonResult)compareForSignatureBaseString:(TXAParam *)other;

@end
