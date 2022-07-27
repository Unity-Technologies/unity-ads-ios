#import "GMAWebViewEvent.h"
#import "NSError+UADSError.h"

@implementation GMAWebViewEvent

+ (instancetype)newWithEventName: (NSString *)event andParams: (NSArray *)params {
    return [self newWithCategory: @"GMA"
                       withEvent: event
                      withParams: params];
}

+ (instancetype)newWithEventName: (NSString *)event andMeta: (GMAAdMetaData *)meta {
    return [self newWithCategory: @"GMA"
                       withEvent: event
                      withParams: [self defaultParamsFromMeta: meta]];
}

+ (NSArray *)defaultParamsFromMeta: (GMAAdMetaData *)meta {
    return @[meta.placementID, meta.queryID];
}

+ (instancetype)newWithEvent: (NSString *)event {
    return [self newWithEventName: event
                        andParams: nil];
}

+ (instancetype)newSignalsEvent: (NSString *)signals {
    NSString *safeSignals = signals ? : @"";

    return [self newWithEventName: @"SIGNALS"
                        andParams: @[safeSignals]];
}

+ (instancetype)newAdLoadedWithMeta: (GMAAdMetaData *)meta
                        andLoadedAd: (GADBaseAd *_Nullable)ad {
    return [self newWithEventName: @"AD_LOADED"
                          andMeta: meta];
}

+ (instancetype)newAdEarnRewardWithMeta: (GMAAdMetaData *)meta {
    return [self newWithEventName: @"AD_EARNED_REWARD"
                          andMeta: meta];
}

+ (instancetype)newAdStartedWithMeta: (GMAAdMetaData *)meta   {
    return [self newWithEventName: @"AD_STARTED"
                          andMeta: meta];
}

+ (instancetype)newFirstQuartileWithMeta: (GMAAdMetaData *)meta  {
    return [self newWithEventName: @"FIRST_QUARTILE"
                          andMeta: meta];
}

+ (instancetype)newMidPointWithMeta: (GMAAdMetaData *)meta  {
    return [self newWithEventName: @"MIDPOINT"
                          andMeta: meta];
}

+ (instancetype)newThirdQuartileWithMeta: (GMAAdMetaData *)meta  {
    return [self newWithEventName: @"THIRD_QUARTILE"
                          andMeta: meta];
}

+ (instancetype)newLastQuartileWithMeta: (GMAAdMetaData *)meta  {
    return [self newWithEventName: @"LAST_QUARTILE"
                          andMeta: meta];
}

+ (instancetype)newAdSkippedWithMeta: (GMAAdMetaData *)meta  {
    return [self newWithEventName: @"AD_SKIPPED"
                          andMeta: meta];
}

+ (instancetype)newAdClosedWithMeta: (GMAAdMetaData *)meta  {
    return [self newWithEventName: @"AD_CLOSED"
                          andMeta: meta];
}

+ (instancetype)newAdClickedWithMeta: (GMAAdMetaData *)meta  {
    return [self newWithEventName: @"AD_CLICKED"
                          andMeta: meta];
}

+ (instancetype)newScarPresent  {
    return [self newWithEvent: @"SCAR_PRESENT"];
}

+ (instancetype)newScarNotPresent {
    return [self newWithEvent: @"SCAR_NOT_PRESENT"];
}

+ (instancetype)newScarUnsupported  {
    return [self newWithEvent: @"SCAR_UNSUPPORTED"];
}

+ (instancetype)newImpressionRecordedWithMeta: (GMAAdMetaData *)meta {
    NSString *event = meta.type == GADQueryInfoAdTypeRewarded ? @"REWARDED_IMPRESSION_RECORDED" : @"INTERSTITIAL_IMPRESSION_RECORDED";

    return [self newWithEventName: event
                          andMeta: meta];
}

@end
