#import "UADSWebPlayerError.h"

static NSString *unityAdsWebPlayerNull = @"WEBPLAYER_NULL";

NSString *UADSNSStringFromWebPlayerError(UnityAdsWebPlayerError error) {
    switch (error) {
        case kUnityAdsWebPlayerNull:
            return unityAdsWebPlayerNull;
    }
}
