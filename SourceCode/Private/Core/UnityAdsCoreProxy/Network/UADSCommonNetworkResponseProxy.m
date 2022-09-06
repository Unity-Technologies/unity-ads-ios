
#import "UADSCommonNetworkResponseProxy.h"

@implementation UADSCommonNetworkResponseProxy

- (NSString *)id {
    return [self valueForKey: @"id"];
}

- (NSString *)body {
    return [self valueForKey: @"response"];
}

- (NSNumber *)status {
    return [self valueForKey: @"responseCode"];
}

- (NSDictionary *)headers {
    return [self valueForKey: @"headers"];
}

- (NSDictionary *)urlString {
    return [self valueForKey: @"url"];
}

@end
