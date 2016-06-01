#import "UADSResolveEvent.h"

static NSString *complete = @"COMPLETE";
static NSString *failed = @"FAILED";

NSString *NSStringFromResolveEvent(UnityAdsResolveEvent event) {
    switch (event) {
        case kUnityAdsResolveEventComplete:
            return complete;
        case kUnityAdsResolveEventFailed:
            return failed;
    }
}
