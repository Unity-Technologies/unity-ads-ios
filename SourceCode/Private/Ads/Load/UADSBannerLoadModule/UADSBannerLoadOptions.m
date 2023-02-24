#import "UADSBannerLoadOptions.h"
#import "UADSTools.h"

@implementation UADSBannerLoadOptions

+(instancetype)newBannerLoadOptionsWith:(UADSLoadOptions *)loadOptions size:(CGSize)size {
    UADSBannerLoadOptions *bannerOptions = [UADSBannerLoadOptions new];
    [loadOptions.dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [bannerOptions.dictionary setValue:obj forKey:key];
    }];
    bannerOptions.size = size;
    return bannerOptions;
}

@end
