#import "GADResponseInfoBridge.h"

static NSString *const kResponseIdentifierKey = @"responseIdentifier";

@implementation GADResponseInfoBridge

+ (NSString *)className {
    return @"GADResponseInfo";
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[kResponseIdentifierKey];
}

- (NSString *)responseIdentifier {
    return [self.proxyObject valueForKey: kResponseIdentifierKey];
}

@end
