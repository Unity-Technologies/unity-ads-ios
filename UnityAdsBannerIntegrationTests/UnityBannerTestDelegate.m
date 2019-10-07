#import "UnityBannerTestDelegate.h"

@implementation UnityBannerTestDelegate

-(void)unityAdsBannerDidLoad:(NSString *)placementId view:(UIView *)view {
    if (_didLoadBlock) {
        _didLoadBlock(placementId, view);
    }
}

-(void)unityAdsBannerDidUnload:(NSString *)placementId {
    if (_didUnloadBlock) {
        _didUnloadBlock(placementId);
    }
}

-(void)unityAdsBannerDidShow:(NSString *)placementId {
    if (_didShowBlock) {
        _didShowBlock(placementId);
    }
}

-(void)unityAdsBannerDidHide:(NSString *)placementId {
    if (_didHideBlock) {
        _didHideBlock(placementId);
    }
}

-(void)unityAdsBannerDidClick:(NSString *)placementId {
    if (_didClickBlock) {
        _didClickBlock(placementId);
    }
}

-(void)unityAdsBannerDidError:(NSString *)message {
    if (_didErrorBlock) {
        _didErrorBlock(message);
    }
}

@end
