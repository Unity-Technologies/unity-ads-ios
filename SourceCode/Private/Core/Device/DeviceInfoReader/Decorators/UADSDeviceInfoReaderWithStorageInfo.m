#import "UADSDeviceInfoReaderWithStorageInfo.h"
#import "NSDictionary+Merge.h"
#import "USRVStorageManager.h"
#import "USRVJsonStorageAggregator.h"
#import "UADSJsonStorageKeyNames.h"
#import "UADSTools.h"
@import WebKit;

@interface UADSDeviceInfoReaderWithStorageInfo ()
@property (nonatomic, strong) id<UADSDeviceInfoReader> original;
@property (nonatomic, strong) id<UADSJsonStorageContentsReader> jsonStorageReader;
@property (nonatomic, strong) id<UADSDeviceInfoStorageKeysProvider>keysProvider;
@end

@implementation UADSDeviceInfoReaderWithStorageInfo

+ (instancetype)defaultDecorationOfOriginal: (id<UADSDeviceInfoReader>)original
                            andKeysProvider: (id<UADSDeviceInfoStorageKeysProvider>)keysProvider {
    return [UADSDeviceInfoReaderWithStorageInfo decorateOriginal: original
                                            andJSONStorageReader: [USRVJsonStorageAggregator defaultAggregator]
                                                    keysProvider: keysProvider];
}

+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
            andJSONStorageReader: (id<UADSJsonStorageContentsReader>)jsonStorageReader
                    keysProvider: (id<UADSDeviceInfoStorageKeysProvider>)keysProvider {
    UADSDeviceInfoReaderWithStorageInfo *decorator = [UADSDeviceInfoReaderWithStorageInfo new];

    decorator.jsonStorageReader = jsonStorageReader;
    decorator.original = original;
    decorator.keysProvider = keysProvider;
    return decorator;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSDictionary *originalInfo = [self.original getDeviceInfoForGameMode: mode];
    __block NSDictionary *storageContent;

    uads_measure_performance_and_log(@"storage get contents", ^{
        storageContent = [self.jsonStorageReader getContents];
    });

    uads_measure_performance_and_log(@"storage flat", ^{
        storageContent = [storageContent uads_flatUsingSeparator: @"."
                                             includeTopLevelKeys: self.keysProvider.topLevelKeysToInclude
                                                   andReduceKeys: self.keysProvider.keysToReduce
                                                     andSkipKeys: self.keysProvider.keysToExclude];
    });


    uads_measure_performance_and_log(@"storage merge", ^{
        storageContent = [originalInfo uads_newdictionaryByMergingWith: storageContent];
    });

    return storageContent;
}

@end
