#import "UADSDeviceInfoExcludeFieldsProvider.h"
#import "UADSTools.h"
#import "USRVJsonStorageAggregator.h"
#import "USRVStorageManager.h"
#import "UADSJsonStorageKeyNames.h"
#import "NSDictionary+Merge.h"
#import "NSArray + Map.h"

@interface UADSDeviceInfoExcludeFieldsProvider ()
@property (nonatomic, strong) id<UADSJsonStorageReader> jsonStorage;
@end

@implementation UADSDeviceInfoExcludeFieldsProvider

+ (id<UADSDictionaryKeysBlockList>)defaultProvider {
    USRVJsonStorage *privateStorage = [USRVStorageManager getStorage: kUnityServicesStorageTypePrivate];

    return [self newWithJSONStorage: privateStorage];
}

+ (instancetype)newWithJSONStorage: (id<UADSJsonStorageReader>)jsonStorage {
    UADSDeviceInfoExcludeFieldsProvider *provider = [self new];

    provider.jsonStorage = jsonStorage;
    return provider;
}

- (nonnull NSArray<NSString *> *)keysToSkip {
    return [self.defaultPIIKeysToExclude arrayByAddingObjectsFromArray: self.filtersFromTheStorage];
}

- (nonnull NSArray<NSString *> *)filtersFromTheStorage {
    id excludeFieldsObj = [_jsonStorage getValueForKey: self.excludeValuesKey];

    NSString *excludeFieldsString = typecast(excludeFieldsObj, [NSString class]);

    if (excludeFieldsString) {
        return [excludeFieldsString componentsSeparatedByString: @","];
    } else {
        NSArray *array = typecast(excludeFieldsObj, [NSArray class]);
        return [array uads_filter:^BOOL (id _Nonnull obj) {
            return [obj isKindOfClass: [NSString class]];
        }];
    }
}

- (NSString *)excludeValuesKey {
    return [UADSJsonStorageKeyNames excludeDeviceInfoKey];
}

- (NSArray<NSString *> *)defaultPIIKeysToExclude {
    return @[];
    //decide if we want to hardcode those
    //return @[@"vendorIdentifier", @"advertisingTrackingId"];
}

@end
