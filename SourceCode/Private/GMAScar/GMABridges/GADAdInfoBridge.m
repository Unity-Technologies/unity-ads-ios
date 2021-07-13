#import "GADAdInfoBridge.h"

#define INIT_SELECTOR @"initWithQueryInfo:adString:"

@implementation GADAdInfoBridge

+ (NSString *)className {
    return @"GADAdInfo";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[INIT_SELECTOR];
}

+ (nullable instancetype)newWithQueryInfo: (GADQueryInfoBridge *)queryInfo
                                 adString: (NSString *)string {
    return [self getInstanceUsingMethod: INIT_SELECTOR
                                   args: @[queryInfo, string]];
}

@end
