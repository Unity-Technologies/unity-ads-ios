NS_ASSUME_NONNULL_BEGIN

/**
 *  The `UnityAdsLoadDelegate` protocol defines the required methods for receiving messages from UnityAds.load() method.
 */
@protocol UnityAdsLoadDelegate <NSObject>
/**
 *  Callback triggered when a load request has successfully filled the specified placementId with an ad that is ready to show.
 *
 *  @param placementId The ID of the placement as defined in Unity Ads admin tools.
 */
- (void)unityAdsAdLoaded:(NSString *)placementId;
/**
*  Callback triggered when load request has failed to load an ad for a requested placement.
*
*  @param placementId The ID of the placement as defined in Unity Ads admin tools.
*/
- (void)unityAdsAdFailedToLoad:(NSString *)placementId;
@end

NS_ASSUME_NONNULL_END
