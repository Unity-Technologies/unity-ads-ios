#import "UnityAnalyticsAcquisitionType.h"

NSString *NSStringFromUnityAnalyticsAcquisitionType(UnityAnalyticsAcquisitionType acquisitionType) {
    switch (acquisitionType) {
        case kUnityAnalyticsAcquisitionTypePremium:
            return @"premium";
        case kUnityAnalyticsAcquisitionTypeSoft:
            return @"soft";
        default:
            return @"";
    }
}
