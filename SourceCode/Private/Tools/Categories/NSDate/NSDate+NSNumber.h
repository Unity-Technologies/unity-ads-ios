
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (NSNumber)
- (NSNumber *)    uads_timeIntervalSince1970;
@end


@interface NSDate (Convenience)
+ (NSTimeInterval)uads_currentTimestampSince1970;
@end
NS_ASSUME_NONNULL_END
