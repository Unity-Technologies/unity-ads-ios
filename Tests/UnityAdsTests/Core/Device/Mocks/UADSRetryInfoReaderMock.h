#import "UADSInitializeEventsMetricSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSRetryInfoReaderMock : NSObject <UADSRetryInfoReader>
+ (instancetype)newWithInfo: (NSDictionary *)info;
@end

NS_ASSUME_NONNULL_END
