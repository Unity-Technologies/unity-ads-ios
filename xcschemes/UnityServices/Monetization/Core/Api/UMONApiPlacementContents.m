#import "UMONApiPlacementContents.h"
#import "UMONPlacementContent.h"
#import "UMONPlacementContentFactory.h"
#import "UMONPlacementContents.h"
#import "UMONShowAdPlacementContent.h"
#import "UMONShowAdDelegateManager.h"

UnityAdsFinishState UMONUnityAdsFinishStateFromNSString(NSString *state) {
    if (state) {
        if ([state isEqualToString:@"COMPLETED"]) {
            return kUnityAdsFinishStateCompleted;
        } else if ([state isEqualToString:@"SKIPPED"]) {
            return kUnityAdsFinishStateSkipped;
        } else if ([state isEqualToString:@"ERROR"]) {
            return kUnityAdsFinishStateError;
        }
    }

    return -10000;
}

@implementation UMONApiPlacementContents
+(void)WebViewExposed_createPlacementContent:(NSString *)placementId withParams:(NSDictionary *)params withCallBack:(USRVWebViewCallback *)callback {
    UMONPlacementContent *placementContent = [UMONPlacementContentFactory create:placementId withParams:[params mutableCopy]];
    [UMONPlacementContents putPlacementContent:placementId withPlacementContent:placementContent];
    [callback invoke:nil];
}

+(void)WebViewExposed_setPlacementContentState:(NSString *)placementId withState:(NSString *)state withCallBack:(USRVWebViewCallback *)callback {
    [UMONPlacementContents setPlacementContentState:placementId withPlacementContentState:PlacementContentStateFromNSString(state)];
    [callback invoke:nil];
}

+(void)WebViewExposed_sendAdFinished:(NSString *)placementId withFinishState:(NSString *)finishState withCallBack:(USRVWebViewCallback *)callback {
    [[UMONShowAdDelegateManager sharedInstance] sendAdFinished:placementId withFinishState:UMONUnityAdsFinishStateFromNSString(finishState)];
    [callback invoke:nil];
}
+(void)WebViewExposed_sendAdStarted:(NSString *)placementId withCallBack:(USRVWebViewCallback *)callback {
    [[UMONShowAdDelegateManager sharedInstance] sendAdStarted:placementId];
    [callback invoke:nil];
}
@end
