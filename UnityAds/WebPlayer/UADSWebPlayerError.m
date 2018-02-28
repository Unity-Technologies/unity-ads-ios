#import "UADSWebPlayerError.h"

static NSString *unityAdsWebPlayerNull = @"WEBPLAYER_NULL";

NSString *NSStringFromWebPlayerError(UnityAdsWebPlayerError error) {
    switch (error) {
        case kUnityAdsWebPlayerNull:
            return unityAdsWebPlayerNull;
    }
}
