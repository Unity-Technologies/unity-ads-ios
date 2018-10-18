/**
 * An enumeration for the various ways to position the Unity Ads banner placement.
 */
typedef NS_ENUM(NSInteger, UADSBannerPosition) {
    kUnityAdsBannerPositionTopLeft,
    kUnityAdsBannerPositionTopCenter,
    kUnityAdsBannerPositionTopRight,
    kUnityAdsBannerPositionBottomLeft,
    kUnityAdsBannerPositionBottomCenter,
    kUnityAdsBannerPositionBottomRight,
    kUnityAdsBannerPositionCenter,
    kUnityAdsBannerPositionNone
};

UADSBannerPosition UADSBannerPositionFromNSString(NSString *);
