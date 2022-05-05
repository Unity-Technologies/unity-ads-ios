#import "USRVSDKMetrics.h"
#import "UADSConfigurationCRUDBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSender : NSObject <ISDKMetrics>

@property (nonatomic, strong, nullable) NSString *metricEndpoint;

+ (instancetype)newWithConfigurationReader: (id<UADSConfigurationReader>)configReader
                         andRequestFactory: (id<IUSRVWebRequestFactoryStatic>)factory;


@end

NS_ASSUME_NONNULL_END
