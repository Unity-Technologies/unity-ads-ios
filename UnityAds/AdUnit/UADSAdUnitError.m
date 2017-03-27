#import "UADSAdUnitError.h"

static NSString *unityAdsAdUnitNull = @"ADUNIT_NULL";
static NSString *unityAdsAdUnitNoRotationZ = @"NO_ROTATION_Z";
static NSString *unityAdsAdUnitUnknownView = @"UNKNOWN_VIEW";

NSString *NSStringFromAdUnitError(UnityAdsAdUnitError error) {
    switch (error) {
        case kUnityAdsAdUnitNull:
            return unityAdsAdUnitNull;
        case kUnityAdsAdUnitNoRotationZ:
            return unityAdsAdUnitNoRotationZ;
        case kUnityAdsAdUnitUnknownView:
            return unityAdsAdUnitUnknownView;
    }
}
