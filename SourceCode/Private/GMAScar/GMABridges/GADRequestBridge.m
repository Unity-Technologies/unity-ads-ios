#import "GADRequestBridge.h"

#define INFO_KEY         @"adInfo"
#define REQUEST_SELECTOR @"request"
@implementation GADRequestBridge

+ (NSString *)className {
    return @"GADRequest";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[REQUEST_SELECTOR];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[INFO_KEY];
}

+ (instancetype)getNewRequest {
    return [self getInstanceUsingClassMethod: REQUEST_SELECTOR
                                        args: @[]];
}

- (GADAdInfoBridge *)adInfo {
    return [self valueForKey: INFO_KEY];
}

- (void)setAdInfo: (GADAdInfoBridge *)adInfo {
    [self.proxyObject setValue: adInfo
                        forKey: INFO_KEY];
}

@end
