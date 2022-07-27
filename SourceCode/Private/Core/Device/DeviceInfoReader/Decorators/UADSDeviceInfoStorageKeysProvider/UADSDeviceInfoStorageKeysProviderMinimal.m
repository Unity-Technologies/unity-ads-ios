#import "UADSDeviceInfoStorageKeysProviderMinimal.h"
#import "UADSJsonStorageKeyNames.h"
@implementation UADSDeviceInfoStorageKeysProviderMinimal

- (NSArray<NSString *> *)keysToReduce {
    return @[
        @"value"
    ];
}

- (NSArray<NSString *> *)keysToExclude {
    return @[
        @"ts",
    ];
}

- (NSArray<NSString *> *)topLevelKeysToInclude {
    return @[
        kPrivacyContainerName,
        kGDPRContainerName,
        kUnityContainerName,
        kPIPLContainerName,
    ];
}

@end
