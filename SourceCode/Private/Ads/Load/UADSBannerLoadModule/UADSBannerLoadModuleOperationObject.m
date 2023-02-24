#import "UADSBannerLoadModuleOperationObject.h"
#import "UADSBannerLoadOptions.h"
@implementation UADSBannerLoadModuleOperationObject
- (NSString *)methodName {
    return @"load";
}

- (nonnull NSString *)className {
    return kWebViewClassName;
}

- (nonnull NSDictionary *)dictionary {
    CGSize bannerSize = ((UADSBannerLoadOptions *)self.options).size;
    return @{
        kUADSOptionsDictionaryKey: @{
            kUADSHeaderBiddingOptionsDictionaryKey: self.options.dictionary
        },
        kUADSTimestampKey: self.time,
        kUADSPlacementIDKey: self.placementID,
        kUADSListenerIDKey: self.id,
        kUADSBannerWidth: @(bannerSize.width),
        kUADSBannerHeight: @(bannerSize.height)
    };
}

@end
