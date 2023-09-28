#import "GMABannerWebViewEvent.h"

@implementation GMABannerWebViewEvent

+ (instancetype)newWithEventName: (NSString *)event andMeta: (GMAAdMetaData *)meta {
    return [self newWithCategory: @"BANNER"
                       withEvent: event
                      withParams: [self defaultParamsFromMeta: meta]];
}

+ (NSArray *)defaultParamsFromMeta: (GMAAdMetaData *)meta {
    return @[meta.bannerAdId];
}

+ (instancetype)newBannerLoadedWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_LOADED"
                          andMeta: meta];
}

+ (instancetype)newBannerLoadFailedWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_LOAD_FAILED"
                          andMeta: meta];
}

+ (instancetype)newBannerOpenedWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_OPENED"
                          andMeta: meta];
}

+ (instancetype)newBannerClosedWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_CLOSED"
                          andMeta: meta];
}

+ (instancetype)newBannerImpressionWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_IMPRESSION"
                          andMeta: meta];
}

+ (instancetype)newBannerClickedWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_CLICKED"
                          andMeta: meta];
}

+ (instancetype)newBannerAttachedWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_ATTACHED"
                          andMeta: meta];
}

+ (instancetype)newBannerDetachedWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"SCAR_BANNER_DETACHED"
                          andMeta: meta];
}

@end
