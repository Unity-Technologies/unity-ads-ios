#import <Foundation/Foundation.h>
#import "UADSDeviceInfoProvider.h"
#import "UADSDeviceInfoReader.h"
#import "UADSPIIDataSelector.h"
#import "USRVSDKMetrics.h"
#import "UADSDeviceInfoExcludeFieldsProvider.h"
#import "UADSPrivacyStorage.h"
#import "UADSLogger.h"
#import "UADSGameSessionIdReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderBuilder : NSObject <UADSDeviceInfoProvider>
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSDictionaryKeysBlockList>storageBlockListProvider;
@property (nonatomic, strong) id<UADSPrivacyResponseReader>privacyReader;
@property (nonatomic, strong) id<UADSLogger>logger;
@property (nonatomic, strong) id<UADSCurrentTimestamp>currentTimeStampReader;
@property (nonatomic, strong) id<UADSClientConfig> clientConfig;
@property (nonatomic, strong) id<UADSGameSessionIdReader>gameSessionIdReader;
@property BOOL extendedReader;
- (id<UADSDeviceInfoReader>)defaultReader;

@end

NS_ASSUME_NONNULL_END
