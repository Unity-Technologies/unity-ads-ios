#import "UADSDeviceInfoReaderBuilder.h"
#import "UADSDeviceInfoReaderWithStorageInfo.h"
#import "UADSDeviceInfoReader.h"
#import "UADSDeviceInfoReaderWithFilter.h"
#import "UADSDeviceInfoReaderWithMetrics.h"
#import "USRVStorageManager.h"
#import "UADSDeviceIDFIReader.h"
#import "UADSPIITrackingStatusReader.h"
#import "USRVJsonStorageAggregator.h"
#import "UADSMinDeviceInfoReader.h"
#import "UADSDeviceInfoStorageKeysProviderExtended.h"
#import "UADSDeviceInfoStorageKeysProviderMinimal.h"
#import "UADSDeviceInfoReaderWithPrivacy.h"
#import "UADSDeviceInfoReaderGate.h"
#import "UADSDeviceInfoReaderWithSessionId.h"

@implementation UADSDeviceInfoReaderBuilder
- (id<UADSDeviceInfoReader>)defaultReader {
    return [self readerWithExtended: self.extendedReader];
}

- (id<UADSDeviceInfoReader>)readerWithExtended:(BOOL)extendedReader {
    id<UADSDeviceInfoReader> deviceInfoReader = self.minimalDeviceInfoReader;

    if (extendedReader) {
        deviceInfoReader = [self extendOriginal: deviceInfoReader
                                      usingIDFIReader: self.idfiReader];
    }

    deviceInfoReader = [self addStorageDumpDecorator: deviceInfoReader];

    if (extendedReader) {
        deviceInfoReader = [self addGate: deviceInfoReader];
        deviceInfoReader = [self addPIIDecorator: deviceInfoReader];
        
        deviceInfoReader = [self addSessionIdDecorator: deviceInfoReader];

        deviceInfoReader = [self addMetrics: deviceInfoReader
                          usingMetricsSender: self.metricsSender
                            currentTimestamp: self.currentTimeStampReader];
        
    }

    deviceInfoReader = [self addFilter: deviceInfoReader];

    return deviceInfoReader;
}

- (id<UADSDeviceInfoReader>)minimalDeviceInfoReader {
    return [UADSMinDeviceInfoReader newWithIDFIReader: self.idfiReader
                                  userContainerReader: self.userStorageReader
                                  gameSessionIdReader: self.gameSessionIdReader
                                         clientConfig: self.clientConfig];
}

- (id<UADSDeviceIDFIReader, UADSAnalyticValuesReader, UADSInitializationTimeStampReader>)idfiReader {
    return [UADSDeviceIDFIReaderBase new];
}

- (id<UADSDeviceInfoReader>)extendOriginal: (id<UADSDeviceInfoReader>)original
                                 usingIDFIReader: (id<UADSAnalyticValuesReader, UADSInitializationTimeStampReader>)analyticValueReader {
    return [UADSDeviceInfoReaderExtended newWithIDFIReader: analyticValueReader
                                               andOriginal: original
                                                 andLogger: self.logger];
}

- (id<UADSDeviceInfoReader>)addStorageDumpDecorator: (id<UADSDeviceInfoReader>)original {
    id<UADSDeviceInfoStorageKeysProvider> keysProvider = self.extendedReader ? [UADSDeviceInfoStorageKeysProviderExtended new] : [UADSDeviceInfoStorageKeysProviderMinimal new];

    return [UADSDeviceInfoReaderWithStorageInfo defaultDecorationOfOriginal: original
                                                            andKeysProvider: keysProvider];
}

- (id<UADSDeviceInfoReader>)addFilter: (id<UADSDeviceInfoReader>)original {
    return [UADSDeviceInfoReaderWithFilter newWithOriginal: original
                                              andBlockList: self.defaultBlockList];
}

- (id<UADSDeviceInfoReader>)addGate: (id<UADSDeviceInfoReader>)original {
    return [UADSDeviceInfoReaderGate decorateOriginal: original
                                    withPrivacyReader: self.privacyReader];
}

- (id<UADSDictionaryKeysBlockList>)defaultBlockList {
    if (_storageBlockListProvider) {
        return _storageBlockListProvider;
    }

    return [UADSDeviceInfoExcludeFieldsProvider defaultProvider];
}

- (id<UADSDeviceInfoReader>)addPIIDecorator: (id<UADSDeviceInfoReader>)original {
        return [UADSDeviceInfoReaderWithPrivacy decorateOriginal: original
                                               withPrivacyReader: self.privacyReader
                                             withPIIDataProvider: [UADSPIIDataProviderBase new]
                                                andUserContainer: self.userStorageReader];
}

- (id<UADSDeviceInfoReader>)addSessionIdDecorator: (id<UADSDeviceInfoReader>)original {
        return [UADSDeviceInfoReaderWithSessionId newWithOriginal: original
                                               andSessionIdReader: self.sharedSessionIdReader];
}

- (id<UADSDeviceInfoReader>)addMetrics: (id<UADSDeviceInfoReader>)original
                    usingMetricsSender: (id<ISDKMetrics>)metricsSender
                      currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader {
    return [UADSDeviceInfoReaderWithMetrics decorateOriginal: original
                                            andMetricsSender: metricsSender
                                            currentTimestamp: timestampReader];
}

- (id<UADSPIITrackingStatusReader>)userStorageReader {
    return [UADSPIITrackingStatusReaderBase newWithStorageReader: USRVJsonStorageAggregator.defaultAggregator];
}

- (id<UADSJsonStorageReader>)privateStorage {
    return [USRVStorageManager getStorage: kUnityServicesStorageTypePrivate];
}

- (NSDictionary *)getDeviceInfoWithExtended:(BOOL)extended {
    return [[self readerWithExtended: extended] getDeviceInfoForGameMode:UADSGameModeMix];
}

@end
