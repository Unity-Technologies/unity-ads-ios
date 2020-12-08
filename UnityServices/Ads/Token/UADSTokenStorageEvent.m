#import "UADSTokenStorageEvent.h"

static NSString *unityAdTokenStorageEventQueueEmpty = @"QUEUE_EMPTY";
static NSString *unityAdTokenStorageEventTokenAccess = @"TOKEN_ACCESS";

NSString *UADSNSStringFromTokenStorageEvent(UnityAdsTokenStorageEvent event) {
    switch (event) {
        case kUnityAdsTokenStorageQueueEmpty:
            return unityAdTokenStorageEventQueueEmpty;
        case kUnityAdsTokenStorageAccessToken:
            return unityAdTokenStorageEventTokenAccess;
    }
}
