#import "GADRequestBridgeV85.h"

#define REQUEST_AGENT_KEY        @"requestAgent"
#define AD_STRING_KEY            @"adString"
#define REGISTER_EXTRAS_SELECTOR @"registerAdNetworkExtras:"

@implementation GADRequestBridgeV85

+ (NSArray<NSString *> *)requiredSelectors {
    return [super.requiredSelectors arrayByAddingObjectsFromArray: @[REGISTER_EXTRAS_SELECTOR]];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return [super.requiredKeysForKVO arrayByAddingObjectsFromArray: @[AD_STRING_KEY, REQUEST_AGENT_KEY]];
}

- (void)registerAdNetworkExtras:(nonnull id)extras {
    [self callInstanceMethod: REGISTER_EXTRAS_SELECTOR args:@[extras]];
}

- (NSString *)requestAgent {
    return [self valueForKey: REQUEST_AGENT_KEY];
}

- (void)setRequestAgent:(NSString *)requestAgent {
    [self.proxyObject setValue: requestAgent
                        forKey: REQUEST_AGENT_KEY];
}

- (NSString *)adString {
    return [self valueForKey: AD_STRING_KEY];
}

- (void)setAdString:(NSString *)adString {
    [self.proxyObject setValue: adString
                        forKey: AD_STRING_KEY];
}

@end
