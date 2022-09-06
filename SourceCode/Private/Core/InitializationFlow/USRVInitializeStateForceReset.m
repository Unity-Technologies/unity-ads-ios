#import "USRVInitializeStateForceReset.h"
#import "USRVSdkProperties.h"

@implementation USRVInitializeStateForceReset : USRVInitializeStateReset

- (instancetype)execute {
    [USRVSdkProperties setInitializationState: NOT_INITIALIZED];
    [super execute];
    return nil;
}

@end
