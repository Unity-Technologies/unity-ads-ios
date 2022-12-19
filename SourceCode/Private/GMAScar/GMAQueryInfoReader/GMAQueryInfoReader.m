#import "GMAQueryInfoReader.h"

@interface GMABaseQueryInfoReader()
@property (nonatomic, strong) id<GMAQueryInfoRequestFactory> requestFactory;
@end

@implementation GMABaseQueryInfoReader

+ (instancetype)newWithRequestFactory:(id<GMAQueryInfoRequestFactory>)factory {
    GMABaseQueryInfoReader *reader = [GMABaseQueryInfoReader new];
    reader.requestFactory = factory;
    return reader;
}

- (void)getQueryInfoOfFormat: (GADQueryInfoAdType)type
                  completion: (nonnull GADQueryInfoBridgeCompletion *)completion {
    GADRequestBridge *request = [self.requestFactory createRequest];
    [GADQueryInfoBridge createQueryInfo: request
                                 format: type
                             completion: completion];
}

@end
