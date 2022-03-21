#import <Foundation/Foundation.h>
#import "USRVInitializationDelegate.h"
#import "USRVSDKMetrics.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "UADSCurrentTimestamp.h"
#import "UADSDeviceIDFIReader.h"
#import "USRVInitializationNotificationCenter.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSTokenAvailabilityType) {
    kUADSTokenAvailabilityTypeWeb,
    kUADSTokenAvailabilityTypeFirstToken
};

@interface UADSInitializeEventsMetricSender : NSObject<UADSInitializationTimeStampReader>
- (instancetype)initWithMetricSender: (id<ISDKMetrics>)metricSender
                          tagsReader: (id<UADSConfigurationMetricTagsReader>)tagReader
                    currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader
                         initSubject: (id<USRVInitializationNotificationCenterProtocol>)initializationSubject;
+ (instancetype)sharedInstance;

- (void)        didInitStart;
- (void)        didConfigRequestStart;
- (void)        sdkDidInitialize;
- (void)sdkInitializeFailed: (NSError *)error;
- (void)sendTokenAvailabilityLatencyOnceOfType: (UADSTokenAvailabilityType)type;
@end

NS_ASSUME_NONNULL_END
