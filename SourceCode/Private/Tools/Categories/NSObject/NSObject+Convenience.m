#import "NSArray+Convenience.h"
#import "NSObject+Convenience.h"

@implementation NSObject (Category)

+ (bool)uads_containsMethods: (NSArray<NSString *> *)names {
    if (names.count == 0) {
        return true;
    }

    return [names uads_allSatisfy: ^bool (NSString *_Nonnull obj) {
        return [self containsMethod: obj];
    }];
}

+ (bool)containsMethod: (NSString *)name {
    bool result = false;
    SEL selector = NSSelectorFromString(name);

    if (!selector) {
        return result;
    }

    result = ([self methodSignatureForSelector: selector] != nil ||
              [self instanceMethodSignatureForSelector: selector] != nil);
    return result;
}

@end
