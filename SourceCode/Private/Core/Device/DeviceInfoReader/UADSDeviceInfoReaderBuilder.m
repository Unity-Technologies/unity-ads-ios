#import "UADSDeviceInfoReaderBuilder.h"
#import "UADSDeviceInfoReaderWithStorageInfo.h"
#import "UADSDeviceInfoReader.h"
#import "UADSDeviceInfoReaderWithFilter.h"
#import "UADSDeviceReaderWithPII.h"
#import "UADSDeviceInfoReaderWithMetrics.h"
#import "USRVStorageManager.h"
#import "UADSDeviceIDFIReader.h"
#import "UADSPIITrackingStatusReader.h"
#import "USRVJsonStorageAggregator.h"

@implementation UADSDeviceInfoReaderBuilder
- (id<UADSDeviceInfoReader>)defaultReaderWithConfig: (id<UADSPIIDataSelectorConfig>)config metricsSender: (id<ISDKMetrics>)metricsSender metricTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader {
    id<UADSDeviceIDFIReader, UADSAnalyticValuesReader, UADSInitializationTimeStampReader>idfiReader = [UADSDeviceIDFIReaderBase new];
    id<UADSDeviceInfoReader> deviceInfoReader = [UADSDeviceInfoReaderBase newWithIDFIReader: idfiReader];

    deviceInfoReader = [self addStorageDumpDecorator: deviceInfoReader];

    deviceInfoReader = [self addPIIDecorator: deviceInfoReader
                                 usingConfig: config];
    deviceInfoReader = [self addFilter: deviceInfoReader];
    deviceInfoReader = [self addMetrics: deviceInfoReader
                     usingMetricsSender: metricsSender
                             tagsReader: tagsReader];

    return deviceInfoReader;
}

- (id<UADSDeviceInfoReader>)addStorageDumpDecorator: (id<UADSDeviceInfoReader>)original {
    return [UADSDeviceInfoReaderWithStorageInfo defaultDecorationOfOriginal: original];
}

- (id<UADSDeviceInfoReader>)addFilter: (id<UADSDeviceInfoReader>)original {
    id<UADSDictionaryKeysBlockList> blockListReader = [UADSDeviceInfoExcludeFieldsProvider defaultProvider];

    return [UADSDeviceInfoReaderWithFilter newWithOriginal: original
                                              andBlockList: blockListReader];
}

- (id<UADSDeviceInfoReader>)addPIIDecorator: (id<UADSDeviceInfoReader>)original
                                usingConfig: (id<UADSPIIDataSelectorConfig>)config {
    return [UADSDeviceReaderWithPII newWithOriginal: original
                                    andDataProvider: [UADSPIIDataProviderBase new]
                                 andPIIDataSelector: [self dataSelectorWithConfig: config]
                                     andJsonStorage: self.privateStorage];
}

- (id<UADSDeviceInfoReader>)addMetrics: (id<UADSDeviceInfoReader>)original
                    usingMetricsSender: (id<ISDKMetrics>)metricsSender
                            tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader {
    return [UADSDeviceInfoReaderWithMetrics defaultDecorationOfOriginal: original
                                                          metricsSender: metricsSender
                                                             tagsReader: tagsReader];
}

- (id<UADSPIIDataSelector>)dataSelectorWithConfig: (id<UADSPIIDataSelectorConfig>)config {
    UADSPIITrackingStatusReaderBase *statusReader =  [UADSPIITrackingStatusReaderBase newWithStorageReader: USRVJsonStorageAggregator.defaultAggregator];

    return [UADSPIIDataSelectorBase newWithJsonStorage: self.privateStorage
                                       andStatusReader: statusReader
                                          andPIIConfig: config];
}

- (id<UADSJsonStorageReader>)privateStorage {
    return [USRVStorageManager getStorage: kUnityServicesStorageTypePrivate];
}

@end
