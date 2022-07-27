#import <Foundation/Foundation.h>
#import "UADSCurrentTimestamp.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSPerformanceMeasurer : NSObject

+ (instancetype)newWithTimestampReader: (id<UADSCurrentTimestamp>)timestampReader;

- (void)startMeasureForSystem: (nonnull NSString *)system;
- (void)startMeasureForSystemIfNeeded: (nonnull NSString *)system;
- (nullable NSNumber *)endMeasureForSystem: (nonnull NSString *)system;
- (BOOL)measureStartedForSystem: (nonnull NSString *)system;
@end

NS_ASSUME_NONNULL_END
