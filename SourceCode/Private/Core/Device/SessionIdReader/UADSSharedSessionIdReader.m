#import "UADSSharedSessionIdReader.h"
#import "UADSServiceProviderContainer.h"

@implementation UADSSharedSessionIdReaderBase

- (nonnull NSString *)sessionId {
    UADSServiceProvider *provider = UADSServiceProviderContainer.sharedInstance.serviceProvider;
    return [provider.objBridge sessionId];
}

@end
