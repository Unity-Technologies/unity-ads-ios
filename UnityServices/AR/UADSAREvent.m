#import "UADSAREvent.h"

static NSString *unityAdsARPlanesAdded = @"AR_PLANES_ADDED";
static NSString *unityAdsARPlanesRemoved = @"AR_PLANES_REMOVED";
static NSString *unityAdsARPlanesUpdated = @"AR_PLANES_UPDATED";
static NSString *unityAdsARAnchorsUpdated = @"AR_ANCHORS_UPDATED";
static NSString *unityAdsARFrameUpdated = @"AR_FRAME_UPDATED";
static NSString *unityAdsARWindowResized = @"AR_WINDOW_RESIZED";
static NSString *unityAdsARError = @"AR_ERROR";
static NSString *unityAdsARSessionInterrupted = @"AR_SESSION_INTERRUPTED";
static NSString *unityAdsARSessionInterruptionEnded = @"AR_SESSION_INTERRUPTION_ENDED";

NSString *NSStringFromAREvent(UnityAdsAREvent event) {
    switch (event) {
        case kUnityAdsARPlanesAdded:
            return unityAdsARPlanesAdded;
        case kUnityAdsARPlanesRemoved:
            return unityAdsARPlanesRemoved;
        case kUnityAdsARPlanesUpdated:
            return unityAdsARPlanesUpdated;
        case kUnityAdsARAnchorsUpdated:
            return unityAdsARAnchorsUpdated;
        case kUnityAdsARFrameUpdated:
            return unityAdsARFrameUpdated;
        case kUnityAdsARWindowResized:
            return unityAdsARWindowResized;
        case kUnityAdsARError:
            return unityAdsARError;
        case kUnityAdsARSessionInterrupted:
            return unityAdsARSessionInterrupted;
        case kUnityAdsARSessionInterruptionEnded:
            return unityAdsARSessionInterruptionEnded;
    }
}
