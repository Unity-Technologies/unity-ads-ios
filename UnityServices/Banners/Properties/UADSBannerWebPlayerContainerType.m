#import "UADSBannerWebPlayerContainerType.h"

static NSString *UADSBannerWebPlayerContainerTypeWebPlayerString = @"WEB_PLAYER";
static NSString *UADSBannerWebPlayerContainerTypeUnknownString = @"UNKNOWN";

UADSBannerWebPlayerContainerType UADSBannerWebPlayerContainerTypeFromNSString(NSString *bannerWebPlayerContainerTypeString) {
    if (bannerWebPlayerContainerTypeString) {
        if ([bannerWebPlayerContainerTypeString isEqualToString:UADSBannerWebPlayerContainerTypeWebPlayerString]) {
            return UADSBannerWebPlayerContainerTypeWebPlayer;
        } else if ([bannerWebPlayerContainerTypeString isEqualToString:UADSBannerWebPlayerContainerTypeUnknownString]) {
            return UADSBannerWebPlayerContainerTypeUnknown;
        } else {
            return UADSBannerWebPlayerContainerTypeUnknown;
        }
    } else {
        return UADSBannerWebPlayerContainerTypeUnknown;
    }
}
