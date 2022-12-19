#import "GADExtrasBridge.h"

#define ADDITIONAL_PARAMETERS_KEY @"additionalParameters"
#define INIT @"init"

@implementation GADExtrasBridge

+ (NSString *)className {
    return @"GADExtras";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[INIT];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[ADDITIONAL_PARAMETERS_KEY];
}


+ (instancetype)getNewExtras {
    return [self getInstanceUsingMethod: INIT
                                   args: @[]];
}

- (NSDictionary *)additionalParameters {
    return [self valueForKey: ADDITIONAL_PARAMETERS_KEY];
}

- (void)setAdditionalParameters:(NSDictionary *)additionalParameters {
    [self.proxyObject setValue: additionalParameters
                        forKey: ADDITIONAL_PARAMETERS_KEY];
}

@end
