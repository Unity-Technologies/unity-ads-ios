#import "UnityAds.h"
#import "UMONShowAdPlacementContent.h"

@interface UMONShowAdDelegateManager : NSObject
+(UMONShowAdDelegateManager*)sharedInstance;
-(void)setDelegate:(id<UMONShowAdDelegate>)delegate forPlacementId:(NSString*)placementId;
-(void)sendAdFinished:(NSString*)placementId withFinishState:(UnityAdsFinishState)finishState;
-(void)sendAdStarted:(NSString*)placementId;
@end
