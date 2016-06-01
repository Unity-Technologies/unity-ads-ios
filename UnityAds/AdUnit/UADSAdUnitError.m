#import "UADSAdUnitError.h"

static NSString *unityAdsViewControllerNull = @"VIEW_CONTROLLER_NULL";

NSString *NSStringFromAdUnitError(UnityAdsAdUnitError error) {
    switch (error) {
        case kUnityAdsViewControllerNull:
            return unityAdsViewControllerNull;
    }
}