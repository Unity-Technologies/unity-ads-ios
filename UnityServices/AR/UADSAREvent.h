#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsAREvent) {
    kUnityAdsARPlanesAdded,
    kUnityAdsARPlanesRemoved,
    kUnityAdsARPlanesUpdated,
    kUnityAdsARAnchorsUpdated,
    kUnityAdsARFrameUpdated,
    kUnityAdsARWindowResized,
    kUnityAdsARError,
    kUnityAdsARSessionInterrupted,
    kUnityAdsARSessionInterruptionEnded,
};

NSString *NSStringFromAREvent(UnityAdsAREvent);
