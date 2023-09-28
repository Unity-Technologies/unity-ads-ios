#import "UADSScarSignalParameters.h"

@implementation UADSScarSignalParameters

- (instancetype)initWithPlacementId: (NSString *)placementId adFormat: (GADQueryInfoAdType)adFormat {
    SUPER_INIT;
    _adFormat = adFormat;
    _placementId = placementId;
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:UADSScarSignalParameters.class]) {
        return false;
    }
    UADSScarSignalParameters *other = object;
    return [self.placementId isEqualToString:other.placementId] && self.adFormat == other.adFormat;
}

@end
