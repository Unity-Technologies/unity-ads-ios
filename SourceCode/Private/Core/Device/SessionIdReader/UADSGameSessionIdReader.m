#import "UADSGameSessionIdReader.h"
#import "UADSServiceProviderContainer.h"

@interface UADSGameSessionIdReaderBase ()
@end

@implementation UADSGameSessionIdReaderBase

- (nonnull NSNumber *)gameSessionId {
    UADSServiceProvider *provider = UADSServiceProviderContainer.sharedInstance.serviceProvider;
    return [NSNumber numberWithLongLong: [[provider.objBridge gameSessionId] longLongValue]];
}

@end
