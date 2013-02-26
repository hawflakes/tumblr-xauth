#import "TXARequest.h"

#import <Foundation/Foundation.h>

@interface TXARequest ()
+ (NSString *)generateNonce;
+ (NSString *)generateTimestamp;
@end

@implementation TXARequest

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
