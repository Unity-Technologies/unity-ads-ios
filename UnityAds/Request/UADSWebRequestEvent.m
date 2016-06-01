#import "UADSWebRequestEvent.h"

static NSString *complete = @"COMPLETE";
static NSString *failed = @"FAILED";

NSString *NSStringFromWebRequestEvent(UnityAdsWebRequestEvent event) {
    switch (event) {
        case kUnityAdsWebRequestEventComplete:
            return complete;
        case kUnityAdsWebRequestEventFailed:
            return failed;
    }
}
