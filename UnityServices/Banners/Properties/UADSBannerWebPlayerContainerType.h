#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UADSBannerWebPlayerContainerType) {
    UADSBannerWebPlayerContainerTypeWebPlayer,
    UADSBannerWebPlayerContainerTypeUnknown
};

UADSBannerWebPlayerContainerType UADSBannerWebPlayerContainerTypeFromNSString(NSString *bannerWebPlayerContainerTypeString);
