#import "UADSBannerPosition.h"

static NSString *bannerPositionTopLeft = @"topleft";
static NSString *bannerPositionTopCenter = @"topcenter";
static NSString *bannerPositionTopRight = @"topright";
static NSString *bannerPositionBottomLeft = @"bottomleft";
static NSString *bannerPositionBottomCenter = @"bottomcenter";
static NSString *bannerPositionBottomRight = @"bottomright";
static NSString *bannerPositionCenter = @"center";
static NSString *bannerPositionNone = @"none";

UADSBannerPosition UADSBannerPositionFromNSString(NSString *value) {
    if (value == nil) {
        return kUnityAdsBannerPositionNone;
    } else if ([value isEqualToString:bannerPositionTopLeft]) {
        return kUnityAdsBannerPositionTopLeft;
    } else if ([value isEqualToString:bannerPositionTopCenter]) {
        return kUnityAdsBannerPositionTopCenter;
    } else if ([value isEqualToString:bannerPositionTopRight]) {
        return kUnityAdsBannerPositionTopRight;
    } else if ([value isEqualToString:bannerPositionBottomLeft]) {
        return kUnityAdsBannerPositionBottomLeft;
    } else if ([value isEqualToString:bannerPositionBottomCenter]) {
        return kUnityAdsBannerPositionBottomCenter;
    } else if ([value isEqualToString:bannerPositionBottomRight]) {
        return kUnityAdsBannerPositionBottomRight;
    } else if ([value isEqualToString:bannerPositionCenter]) {
        return kUnityAdsBannerPositionCenter;
    } else {
        return kUnityAdsBannerPositionNone;
    }
}
