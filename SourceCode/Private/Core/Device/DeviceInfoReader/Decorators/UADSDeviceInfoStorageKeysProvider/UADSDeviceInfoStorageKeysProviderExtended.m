#import "UADSDeviceInfoStorageKeysProviderExtended.h"
#import "UADSJsonStorageKeyNames.h"

@implementation UADSDeviceInfoStorageKeysProviderExtended

- (NSArray<NSString *> *)keysToExclude {
    return [super.keysToExclude arrayByAddingObjectsFromArray: @[
                kWebViewExcludeDeviceInfoFieldsKey,
                kWebViewDataPIIKey,
                @"nonBehavioral",
                @"nonbehavioral",
    ]];
}

- (NSArray<NSString *> *)topLevelKeysToInclude {
    return [super.topLevelKeysToInclude arrayByAddingObjectsFromArray: @[
                kMediationContainerName,
                kFrameworkContainerName,
                kAdapterContainerName,
                kConfigurationContainerName,
                kUADSUserContainerName,
                [UADSJsonStorageKeyNames webViewContainerKey],
    ]];
}

@end
