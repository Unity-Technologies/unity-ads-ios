#import "UADSCommonNetworkErrorProxy.h"

@implementation UADSCommonNetworkErrorProxy
- (NSString *)requestID {
    return [self valueForKey: @"requestID"];
}

- (NSString *)message {
    return [self valueForKey: @"message"];
}

- (NSString *)requestURL {
    return [self valueForKey: @"requestURL"];
}

@end
