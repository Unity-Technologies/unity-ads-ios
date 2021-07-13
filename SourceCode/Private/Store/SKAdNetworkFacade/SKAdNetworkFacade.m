#import "SKAdNetworkFacade.h"
#import "UADSStoreKitLoader.h"
#import "SKAdNetworkProxy.h"


@implementation SKAdNetworkFacade

_uads_custom_singleton_imp(SKAdNetworkFacade, ^{
    [UADSStoreKitLoader loadFrameworkIfNotLoaded];
    return [[self alloc] init];
})

- (void)startImpression: (NSDictionary *)impressionJSON
      completionHandler: (UADSNSErrorCompletion)completion {
    SKAdImpressionProxy *impressionProxy = [SKAdImpressionProxy newFromJSON: impressionJSON];

    [SKAdNetworkProxy startImpression: impressionProxy
                    completionHandler : completion];
}

- (void)endImpression: (NSDictionary *)impressionJSON
    completionHandler: (UADSNSErrorCompletion)completion {
    SKAdImpressionProxy *impressionProxy = [SKAdImpressionProxy newFromJSON: impressionJSON];

    [SKAdNetworkProxy endImpression: impressionProxy
                  completionHandler: completion];
}

@end
