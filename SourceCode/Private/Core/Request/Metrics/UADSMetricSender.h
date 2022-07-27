#import "USRVSDKMetrics.h"
#import "UADSConfigurationCRUDBase.h"
#import "UADSPrivacyStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSender : NSObject <ISDKMetrics, ISDKPerformanceMetricsSender>

@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@property (nonatomic, assign) UADSMetricSenderState state;

+ (instancetype)newWithConfigurationReader: (id<UADSConfigurationReader, UADSConfigurationMetricTagsReader>)configReader
                         andRequestFactory: (id<IUSRVWebRequestFactory>)factory
                             storageReader: (id<UADSJsonStorageReader>)storageReader
                             privacyReader: (id<UADSPrivacyResponseReader>)privacyReader;


@end

NS_ASSUME_NONNULL_END
