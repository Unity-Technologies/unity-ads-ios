#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kUADSLastKnownSystemVersionKey;
extern NSString *const kUADSLastKnownUserAgent;

@interface UADSUserAgentStorage : NSObject
- (NSString *)userAgent;
- (void)      generateAndSaveIfNeed;
@end

NS_ASSUME_NONNULL_END
