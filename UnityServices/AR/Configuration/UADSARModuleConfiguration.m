#import "UADSARModuleConfiguration.h"

@implementation UADSARModuleConfiguration

- (NSArray<NSString*>*)getWebAppApiClassList {
    return @[
             @"UARApiAR",
             ];
}

- (BOOL)resetState:(USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initModuleState:(USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return true;
}

- (BOOL)initCompleteState:(USRVConfiguration *)configuration {
    return true;
}

- (NSDictionary<NSString*, NSString*>*)getAdUnitViewHandlers {
    return @{@"arview" : @"UADSARViewHandler"};
}

@end
