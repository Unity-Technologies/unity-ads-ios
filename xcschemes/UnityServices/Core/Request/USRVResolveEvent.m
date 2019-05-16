#import "USRVResolveEvent.h"

static NSString *complete = @"COMPLETE";
static NSString *failed = @"FAILED";

NSString *USRVNSStringFromResolveEvent(UnityServicesResolveEvent event) {
    switch (event) {
        case kUnityServicesResolveEventComplete:
            return complete;
        case kUnityServicesResolveEventFailed:
            return failed;
    }
}
