#import "UADSWebRequestError.h"

static NSString *requestTimedOut = @"ERROR_REQUEST_TIMED_OUT";
static NSString *genericError = @"GENERIC_ERROR";

NSString *NSStringFromWebRequestError(UnityAdsWebRequestError error) {
    switch (error) {
        case kUnityAdsWebRequestErrorRequestTimedOut:
            return requestTimedOut;
        case kUnityAdsWebRequestGenericError:
            return genericError;
    }
}
