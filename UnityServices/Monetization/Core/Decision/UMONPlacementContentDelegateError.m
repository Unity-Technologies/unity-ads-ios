#import "UMONPlacementContentDelegateError.h"

NSString *NSStringFromPlacementContentDelegateError(UMONPlacementContentDelegateError error) {
    switch (error) {
        case kPlacementDelegateErrorDelegateDidError:
            return @"kPlacementDelegateErrorDelegateDidError";
        case kPlacementDelegateErrorDelegateNull:
            return @"kPlacementDelegateErrorDelegateNull";
    }
}
