#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UADSBannerRefreshInfo : NSObject

+ (instancetype)sharedInstance;

- (void)        setRefreshRateForPlacementId: (NSString *)placementId refreshRate: (NSNumber *)refreshRate;

- (NSNumber *__nullable)getRefreshRateForPlacementId: (NSString *)placementId;

@end

NS_ASSUME_NONNULL_END
