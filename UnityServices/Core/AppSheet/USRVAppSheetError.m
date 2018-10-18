#import "USRVAppSheetError.h"

static NSString *alreadyPreparing = @"ALREADY_PREPARING";
static NSString *alreadyPresenting = @"ALREADY_PRESENTING";
static NSString *appSheetNotFound = @"APPSHEET_NOT_FOUND";
static NSString *noAppSheetFound = @"NO_APPSHEET_FOUND";
static NSString *timeoutError = @"ERROR_TIMEOUT";

NSString *NSStringFromAppSheetError(UnityServicesAppSheetError error) {
    switch (error) {
        case kUnityServicesAppSheetErrorAlreadyPreparing:
            return alreadyPreparing;
        case kUnityServicesAppSheetErrorAlreadyPresenting:
            return alreadyPresenting;
        case kUnityServicesAppSheetErrorNotFound:
            return appSheetNotFound;
        case kUnityServicesAppSheetErrorNoAppSheetFound:
            return noAppSheetFound;
        case kUnityServicesAppSheetErrorTimeout:
            return timeoutError;
    }
}
