#import "USRVJsonStorageAggregator.h"
#import "NSDictionary+Merge.h"
#import "USRVStorageManager.h"

@interface USRVJsonStorageAggregator ()
@property (nonatomic, strong) NSArray<id<UADSJsonStorageContentsReader, UADSJsonStorageReader> > *readers;
@end

@implementation USRVJsonStorageAggregator

+ (instancetype)defaultAggregator {
    USRVJsonStorage *publicStorage = [USRVStorageManager getStorage: kUnityServicesStorageTypePublic];
    USRVJsonStorage *privateStorage = [USRVStorageManager getStorage: kUnityServicesStorageTypePrivate];
    NSMutableArray *readers = [NSMutableArray new];

    if (publicStorage) {
        [readers addObject: publicStorage];
    }

    if (privateStorage) {
        [readers addObject: privateStorage];
    }

    return [USRVJsonStorageAggregator newWithReaders: readers];
}

+ (instancetype)newWithReaders: (NSArray<id<UADSJsonStorageContentsReader, UADSJsonStorageReader> > *)readers {
    USRVJsonStorageAggregator *aggregator = [USRVJsonStorageAggregator new];

    aggregator.readers = readers;
    return aggregator;
}

- (NSDictionary *)getContents {
    NSDictionary *merged = [NSDictionary new];

    for (id<UADSJsonStorageContentsReader> reader in self.readers) {
        merged = [merged uads_newdictionaryByMergingWith: [reader getContents]];
    }

    return merged;
}

- (id)getValueForKey: (NSString *)key {
    __block id returnedValue;

    [_readers enumerateObjectsUsingBlock:^(id<UADSJsonStorageContentsReader, UADSJsonStorageReader>  _Nonnull reader, NSUInteger idx, BOOL *_Nonnull stop) {
        returnedValue = [reader getValueForKey: key];

        *stop = returnedValue != nil;
    }];

    return returnedValue;
}

@end
