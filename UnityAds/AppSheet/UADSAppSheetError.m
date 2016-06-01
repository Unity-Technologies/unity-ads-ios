#import "UADSAppSheetError.h"

static NSString *alreadyPreparing = @"ALREADY_PREPARING";
static NSString *alreadyPresenting = @"ALREADY_PRESENTING";
static NSString *appSheetNotFound = @"APPSHEET_NOT_FOUND";
static NSString *noAppSheetFound = @"NO_APPSHEET_FOUND";
static NSString *timeoutError = @"ERROR_TIMEOUT";

NSString *NSStringFromAppSheetError(UnityAdsAppSheetError error) {
    switch (error) {
        case kUnityAdsAppSheetErrorAlreadyPreparing:
            return alreadyPreparing;
        case kUnityAdsAppSheetErrorAlreadyPresenting:
            return alreadyPresenting;
        case kUnityAdsAppSheetErrorNotFound:
            return appSheetNotFound;
        case kUnityAdsAppSheetErrorNoAppSheetFound:
            return noAppSheetFound;
        case kUnityAdsAppSheetErrorTimeout:
            return timeoutError;
    }
}
