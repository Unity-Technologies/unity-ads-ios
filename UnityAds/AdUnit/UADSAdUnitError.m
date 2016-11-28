#import "UADSAdUnitError.h"

static NSString *unityAdsViewControllerNull = @"VIEW_CONTROLLER_NULL";
static NSString *unityAdsViewControllerNoRotationZ = @"VIEW_CONTROLLER_NO_ROTATION_Z";
static NSString *unityAdsViewControllerUnknownView = @"VIEW_CONTROLLER_UNKNOWN_VIEW";
static NSString *unityAdsViewControllerTargetViewNull = @"VIEW_CONTROLLER_TARGET_VIEW_NULL";

NSString *NSStringFromAdUnitError(UnityAdsAdUnitError error) {
    switch (error) {
        case kUnityAdsViewControllerNull:
            return unityAdsViewControllerNull;
        case kUnityAdsViewControllerNoRotationZ:
            return unityAdsViewControllerNoRotationZ;
        case kUnityAdsViewControllerUnknownView:
            return unityAdsViewControllerUnknownView;
        case kUnityAdsViewControllerTargetViewNull:
            return unityAdsViewControllerTargetViewNull;
    }
}
