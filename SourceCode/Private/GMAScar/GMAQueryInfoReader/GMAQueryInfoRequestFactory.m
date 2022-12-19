#import "GMAQueryInfoRequestFactory.h"

@implementation GMAQueryInfoRequestFactoryBase

- (nonnull GADRequestBridge *)createRequest {
    return [GADRequestBridge getNewRequest];
}

@end

