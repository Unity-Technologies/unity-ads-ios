#import "USRVSDKMetrics.h"
#import <XCTest/XCTest.h>

@interface SDKMetricsSenderMock : NSObject <ISDKMetrics>
@property (nonatomic, strong, nonnull) NSMutableArray<UADSMetric *> *sentMetrics;
@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@property (nonatomic, assign) int callCount;
@property (nonatomic, strong, nullable) XCTestExpectation *exp;
@end
