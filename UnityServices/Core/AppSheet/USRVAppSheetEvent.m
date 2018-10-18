#import "USRVAppSheetEvent.h"

static NSString *prepared = @"PREPARED";
static NSString *opened = @"OPENED";
static NSString *closed = @"CLOSED";
static NSString *failed = @"FAILED";

NSString *NSStringFromAppSheetEvent(UnityServicesAppSheetEvent event) {
    switch (event) {
        case kAppSheetPrepared:
            return prepared;
        case kAppSheetOpened:
            return opened;
        case kAppSheetClosed:
            return closed;
        case kAppSheetFailed:
            return failed;
    }
}
