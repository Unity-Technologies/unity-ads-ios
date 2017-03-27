#import "UADSResolveError.h"

static NSString *timedOut = @"TIMEOUT";
static NSString *unknownHost = @"UNKNOWN_HOST";
static NSString *invalidHost = @"INVALID_HOST";

NSString *NSStringFromResolveError(UnityAdsResolveError error) {
    switch (error) {
        case kUnityAdsResolveErrorTimedOut:
            return timedOut;
        case kUnityAdsResolveErrorUnknownHost:
            return unknownHost;
        case kUnityAdsResolveErrorInvalidHost:
            return invalidHost;
    }
}
