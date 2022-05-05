#import <Foundation/Foundation.h>
#import "UADSMetricsSelector.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSelectorMock : NSObject<UADSMetricsSelector>
@property (nonatomic, assign) BOOL shouldSend;
@end

NS_ASSUME_NONNULL_END
