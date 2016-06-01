#import "UADSResolveError.h"

static NSString *timedOut = @"TIMEOUT";
static NSString *unknownHost = @"UNKNOWN_HOST";
static NSString *unexpectedException = @"UNEXPECTED_EXCEPTION";

NSString *NSStringFromResolveError(UnityAdsResolveError error) {
    switch (error) {
        case kUnityAdsResolveErrorTimedOut:
            return timedOut;
        case kUnityAdsResolveErrorUnknownHost:
            return unknownHost;
        case kUnityAdsResolveErrorUnexpectedException:
            return unexpectedException;
    }
}
