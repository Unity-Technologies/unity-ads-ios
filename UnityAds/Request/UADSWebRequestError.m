#import "UADSWebRequestError.h"

static NSString *requestTimedOut = @"ERROR_REQUEST_TIMED_OUT";
static NSString *genericError = @"GENERIC_ERROR";
static NSString *mappingHeadersFailed = @"MAPPING_HEADERS_FAILED";

NSString *NSStringFromWebRequestError(UnityAdsWebRequestError error) {
    switch (error) {
        case kUnityAdsWebRequestErrorRequestTimedOut:
            return requestTimedOut;
        case kUnityAdsWebRequestGenericError:
            return genericError;
        case kUnityAdsWebRequestErrorMappingHeadersFailed:
            return mappingHeadersFailed;
    }
}
