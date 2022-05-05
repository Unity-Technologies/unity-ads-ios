
#import <Foundation/Foundation.h>
#import "UADSConfigurationCRUDBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationReaderMock : NSObject <UADSConfigurationReader, UADSConfigurationMetricTagsReader>

@property (nonatomic, strong) USRVConfiguration *expectedConfiguration;
+ (instancetype)newWithExperiments: (NSDictionary *)experiments;
@property (nonatomic, strong) NSDictionary *experiments;
@end
NS_ASSUME_NONNULL_END
