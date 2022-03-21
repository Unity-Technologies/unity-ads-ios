#import "UADSDeviceInfoReaderWithStorageInfo.h"
#import "NSDictionary+Merge.h"
#import "USRVStorageManager.h"
#import "USRVJsonStorageAggregator.h"
#import "UADSJsonStorageKeyNames.h"
@import WebKit;

@interface UADSDeviceInfoReaderWithStorageInfo ()
@property (nonatomic, strong) id<UADSDeviceInfoReader> original;
@property (nonatomic, strong) id<UADSJsonStorageContentsReader> jsonStorageReader;
@property (nonatomic, strong) NSArray< NSString *> *includeContainers;
@end

@implementation UADSDeviceInfoReaderWithStorageInfo

+ (instancetype)defaultDecorationOfOriginal: (id<UADSDeviceInfoReader>)original {
    id<UADSJsonStorageContentsReader> storageReader = [USRVJsonStorageAggregator defaultAggregator];
    NSArray *includeTopLevelKeys =  @[
        kMediationContainerName,
        kPrivacyContainerName,
        kGDPRContainerName,
        kFrameworkContainerName,
        kAdapterContainerName,
        kUnityContainerName,
        kPIPLContainerName,
        kConfigurationContainerName,
        kUADSUserContainerName,
        [UADSJsonStorageKeyNames webViewContainerKey],
    ];



    return [UADSDeviceInfoReaderWithStorageInfo decorateOriginal: original
                                            andJSONStorageReader: storageReader
                                               includeContainers: includeTopLevelKeys];
}

+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
            andJSONStorageReader: (id<UADSJsonStorageContentsReader>)jsonStorageReader
               includeContainers: (NSArray< NSString *> *)includeContainers {
    UADSDeviceInfoReaderWithStorageInfo *decorator = [UADSDeviceInfoReaderWithStorageInfo new];

    decorator.jsonStorageReader = jsonStorageReader;
    decorator.original = original;
    decorator.includeContainers = includeContainers;
    return decorator;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSDictionary *originalInfo = [self.original getDeviceInfoForGameMode: mode];
    NSDictionary *storageContent = [self.jsonStorageReader getContents];
    NSDictionary *storageContentFlat = [storageContent uads_flatUsingSeparator: @"."
                                                           includeTopLevelKeys: _includeContainers
                                                                 andReduceKeys: self.keysToReduce
                                                                   andSkipKeys: self.blackListOfKeys];
    NSDictionary *modified = [originalInfo uads_newdictionaryByMergingWith: storageContentFlat];

    return modified;
}

- (NSArray *)blackListOfKeys {
    return @[
        @"ts",
        kWebViewExcludeDeviceInfoFieldsKey,
        kWebViewDataPIIKey,
        @"nonBehavioral",
        @"nonbehavioral",
    ];
}

- (NSArray *)keysToReduce {
    return @[
        @"value"
    ];
}

@end
