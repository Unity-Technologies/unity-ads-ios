#import "USRVResolveError.h"

static NSString *timedOut = @"TIMEOUT";
static NSString *unknownHost = @"UNKNOWN_HOST";
static NSString *invalidHost = @"INVALID_HOST";

NSString * USRVNSStringFromResolveError(UnityServicesResolveError error) {
    switch (error) {
        case kUnityServicesResolveErrorTimedOut:
            return timedOut;

        case kUnityServicesResolveErrorUnknownHost:
            return unknownHost;

        case kUnityServicesResolveErrorInvalidHost:
            return invalidHost;
    }
}
