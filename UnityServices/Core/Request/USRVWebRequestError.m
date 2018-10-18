#import "USRVWebRequestError.h"

static NSString *requestTimedOut = @"ERROR_REQUEST_TIMED_OUT";
static NSString *genericError = @"GENERIC_ERROR";
static NSString *mappingHeadersFailed = @"MAPPING_HEADERS_FAILED";

NSString *NSStringFromWebRequestError(UnityServicesWebRequestError error) {
    switch (error) {
        case kUnityServicesWebRequestErrorRequestTimedOut:
            return requestTimedOut;
        case kUnityServicesWebRequestGenericError:
            return genericError;
        case kUnityServicesWebRequestErrorMappingHeadersFailed:
            return mappingHeadersFailed;
    }
}
