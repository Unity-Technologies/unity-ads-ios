
#import <Foundation/Foundation.h>
#import "UADSConfigurationCRUDBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationReaderMock : NSObject <UADSConfigurationReader, UADSConfigurationMetricTagsReader>

+ (instancetype)newWithExperiments: (NSDictionary *)experiments;
+ (instancetype)newWithMetricURL: (NSString *)metricURL;
@property (nonatomic, strong) USRVConfiguration *expectedConfiguration;
@property (nonatomic, strong) NSDictionary *experiments;
@property (nonatomic, strong) NSString *metricURL;
@property (nonatomic, strong) NSDictionary *expectedMetricInfo;
@end
NS_ASSUME_NONNULL_END
