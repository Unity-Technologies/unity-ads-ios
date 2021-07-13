#import "GADBaseAd.h"

static NSString *const kResponseInfoKey = @"responseInfo";

@implementation GADBaseAd

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[kResponseInfoKey];
}

- (GADResponseInfoBridge *)responseInfo {
    id responseInfo = [self.proxyObject valueForKey: kResponseInfoKey];

    return [GADResponseInfoBridge getProxyWithObject: responseInfo];
}

@end
