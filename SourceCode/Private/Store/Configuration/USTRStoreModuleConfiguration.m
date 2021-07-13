#import "USTRStoreModuleConfiguration.h"

@implementation USTRStoreModuleConfiguration

- (NSArray<NSString *> *)getWebAppApiClassList {
    return @[
        @"USTRApiAppSheet",
        @"USTRApiProducts",
        @"USTRApiSKAdNetwork"
    ];
}

- (BOOL)resetState: (USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initModuleState: (USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initErrorState: (USRVConfiguration *)configuration state: (NSString *)state message: (NSString *)message {
    return true;
}

- (BOOL)initCompleteState: (USRVConfiguration *)configuration {
    return true;
}

@end
