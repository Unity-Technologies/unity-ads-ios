#import "UMONShowAdPlacementContent.h"
#import "UMONShowAdDelegateManager.h"

@implementation UMONShowAdPlacementContent
-(void)show:(UIViewController *)viewController {
    if (self.delegate != nil) {
        [[UMONShowAdDelegateManager sharedInstance] setDelegate:self.delegate forPlacementId:self.placementId];
    }
    if ([UnityAds isReady:self.placementId]) {
        [UnityAds show:viewController placementId:self.placementId];
    } else {
        [[UMONShowAdDelegateManager sharedInstance] sendAdFinished:self.placementId withFinishState:kUnityAdsFinishStateError];
        USRVLogWarning("Ad with placement ID %@ was attempted to show without being ready", self.placementId);
    }
}
-(void)show:(UIViewController *)viewController withDelegate:(id <UMONShowAdDelegate>)delegate {
    self.delegate = delegate;
    [self show:viewController];
}


@end
