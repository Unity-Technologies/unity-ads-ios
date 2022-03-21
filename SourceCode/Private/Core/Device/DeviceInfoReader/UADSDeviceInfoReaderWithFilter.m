#import "UADSDeviceInfoReaderWithFilter.h"
#import "NSDictionary+Filter.h"
@interface UADSDeviceInfoReaderWithFilter ()
@property (nonatomic, strong) id<UADSDeviceInfoReader> original;
@property (nonatomic, strong) id<UADSDictionaryKeysBlockList> blockListReader;
@end

@implementation UADSDeviceInfoReaderWithFilter
+ (id<UADSDeviceInfoReader>)newWithOriginal: (id<UADSDeviceInfoReader>)original
                               andBlockList: (id<UADSDictionaryKeysBlockList>)blockListReader {
    UADSDeviceInfoReaderWithFilter *reader = [UADSDeviceInfoReaderWithFilter new];

    reader.original = original;
    reader.blockListReader = blockListReader;
    return reader;
}

- (NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSDictionary *original = [self.original getDeviceInfoForGameMode: mode];
    NSArray<NSString *> *blockList = self.blockListReader.keysToSkip;

    return [original uads_filter:^BOOL (id _Nonnull key, id _Nonnull obj) {
        return ![blockList containsObject: key];
    }];
}

@end
