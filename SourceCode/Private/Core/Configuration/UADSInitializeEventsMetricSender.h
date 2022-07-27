#import <Foundation/Foundation.h>
#import "USRVInitializationDelegate.h"
#import "USRVSDKMetrics.h"
#import "UADSCurrentTimestamp.h"
#import "UADSDeviceIDFIReader.h"
#import "USRVInitializationNotificationCenter.h"
NS_ASSUME_NONNULL_BEGIN

@protocol UADSRetryInfoReader <NSObject>
- (NSDictionary *)retryTags;
@end

typedef NS_ENUM (NSInteger, UADSTokenAvailabilityType) {
    kUADSTokenAvailabilityTypeWeb,
    kUADSTokenAvailabilityTypeFirstToken
};

@interface UADSInitializeEventsMetricSender : NSObject<UADSInitializationTimeStampReader, UADSRetryInfoReader>
- (instancetype)initWithMetricSender: (id<ISDKMetrics>)metricSender
                    currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader
                         initSubject: (id<USRVInitializationNotificationCenterProtocol>)initializationSubject;
+ (instancetype)  sharedInstance;

- (void)          didInitStart;
- (void)          sdkDidInitialize;
- (void)sdkInitializeFailed: (NSError *)error;
- (void)sendTokenAvailabilityLatencyOnceOfType: (UADSTokenAvailabilityType)type;
- (void)          didRetryConfig;
- (void)          didRetryWebview;
@end

NS_ASSUME_NONNULL_END
