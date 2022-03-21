
#import "UADSInitializationStatusReader.h"

@implementation UADSInitializationStatusReaderBase


- (InitializationState)currentState {
    return [USRVSdkProperties getCurrentInitializationState];
}

@end

static NSString *notInitialized = @"not_initialized";
static NSString *initializing = @"initializing";
static NSString *initializedSuccessfully = @"initialized_successfully";
static NSString *initializedFailed = @"initialized_failed";

NSString * UADSStringFromInitializationState(InitializationState state) {
    switch (state) {
        case NOT_INITIALIZED:
            return notInitialized;

        case INITIALIZING:
            return initializing;

        case INITIALIZED_SUCCESSFULLY:
            return initializedSuccessfully;

        case INITIALIZED_FAILED:
            return initializedFailed;
    }
}
