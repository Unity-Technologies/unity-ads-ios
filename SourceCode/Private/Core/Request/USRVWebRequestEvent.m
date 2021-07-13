#import "USRVWebRequestEvent.h"

static NSString *complete = @"COMPLETE";
static NSString *failed = @"FAILED";

NSString * USRVNSStringFromWebRequestEvent(UnityServicesWebRequestEvent event) {
    switch (event) {
        case kUnityServicesWebRequestEventComplete:
            return complete;

        case kUnityServicesWebRequestEventFailed:
            return failed;
    }
}
