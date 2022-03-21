#import <Foundation/Foundation.h>
#import "USRVWebRequest.h"
#import "UADSDeviceInfoReader.h"
#import "USRVBodyBase64GzipCompressor.h"
#import "UADSBaseURLBuilder.h"
#import "UADSConfigurationRequestFactoryConfig.h"
#import "UADSPIIDataSelector.h"
#import "USRVWebRequestFactory.h"
#import "USRVWebRequestFactory.h"
NS_ASSUME_NONNULL_BEGIN

@protocol USRVConfigurationRequestFactory <NSObject>
- (__nullable id<USRVWebRequest>)configurationRequestFor: (UADSGameMode)mode;
- (NSString *)                   baseURL;
@end

@interface USRVConfigurationRequestFactoryBase : NSObject<USRVConfigurationRequestFactory>

+ (instancetype)newWithCompression: (BOOL)shouldCompress
               andDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                    andBaseBuilder: (id<UADSBaseURLBuilder>)urlBaseBuilder
                  andFactoryConfig: (id<UADSConfigurationRequestFactoryConfig>)config
                     metricsSender: (nullable id<ISDKMetrics>)metricsSender
                  metricTagsReader: (nullable id<UADSConfigurationMetricTagsReader>)tagsReader;

+ (instancetype)defaultFactoryWithConfig: (id<UADSConfigurationRequestFactoryConfig, UADSPIIDataSelectorConfig>)config
                    andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory
                           metricsSender: (id<ISDKMetrics>)metricsSender
                        metricTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader;
@end

NS_ASSUME_NONNULL_END
