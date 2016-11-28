#import "UnityAds.h"

NS_ASSUME_NONNULL_BEGIN
@protocol UnityAdsExtendedDelegate <UnityAdsDelegate>
/**
 *  Called when a click event happens.
 *
 *  @param placementId The ID of the placement that was clicked.
 */
- (void)unityAdsDidClick:(NSString *)placementId;
@end
NS_ASSUME_NONNULL_END
