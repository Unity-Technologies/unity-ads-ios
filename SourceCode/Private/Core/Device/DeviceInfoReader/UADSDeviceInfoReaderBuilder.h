#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "UADSPIIDataSelector.h"
#import "USRVSDKMetrics.h"
#import "UADSDeviceInfoExcludeFieldsProvider.h"
#import "UADSPrivacyStorage.h"
#import "UADSLogger.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderBuilder : NSObject
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSPrivacyConfig,UADSClientConfig> selectorConfig;
@property (nonatomic, strong) id<UADSDictionaryKeysBlockList>storageBlockListProvider;
@property (nonatomic, strong) id<UADSPrivacyResponseReader>privacyReader;
@property (nonatomic, strong) id<UADSLogger>logger;
@property (nonatomic, strong) id<UADSCurrentTimestamp>currentTimeStampReader;
@property BOOL extendedReader;
- (id<UADSDeviceInfoReader>)defaultReader;

@end

NS_ASSUME_NONNULL_END
