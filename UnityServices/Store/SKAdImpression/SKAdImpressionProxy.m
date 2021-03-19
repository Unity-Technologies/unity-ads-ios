#import "SKAdImpressionProxy.h"

@implementation SKAdImpressionProxy
+ (instancetype)newProxy {
    return [self getInstanceUsingMethod:@"init" args:@[]];
}

+(instancetype)newFromJSON: (NSDictionary *)dictionary {
    SKAdImpressionProxy *obj = [self newProxy];
    
    [dictionary.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.proxyObject setValue: dictionary[key] forKey: key];
    }];
    
    return  obj;
}

+ (NSString *)className {
    return  @"SKAdImpression";
}

@end
