#import "UADSPreferencesError.h"

static NSString *unityAdsPreferencesCouldntGetValue = @"COULDNT_GET_VALUE";

NSString *NSStringFromPreferencesError(UnityAdsPreferencesError error) {
    switch (error) {
        case kUnityAdsPreferencesCouldntGetValue:
            return unityAdsPreferencesCouldntGetValue;
    }
}
