#import "GMAQueryInfoReader.h"

@implementation GMABaseQueryInfoReader

- (void)getQueryInfoOfFormat: (GADQueryInfoAdType)type
                  completion: (nonnull GADQueryInfoBridgeCompletion *)completion {
    GADRequestBridge *request = [GADRequestBridge getNewRequest];

    [GADQueryInfoBridge createQueryInfo: request
                                 format: type
                             completion: completion];
}

@end
