#import "UADSAdUnitEvent.h"

static NSString *unityAdsViewInit = @"VIEW_CONTROLLER_INIT";
static NSString *unityAdsViewDidLoad = @"VIEW_CONTROLLER_DID_LOAD";
static NSString *unityAdsViewDidAppear = @"VIEW_CONTROLLER_DID_APPEAR";
static NSString *unityAdsViewWillDisappear = @"VIEW_CONTROLLER_WILL_DISAPPEAR";
static NSString *unityAdsViewDidDisappear = @"VIEW_CONTROLLER_DID_DISAPPEAR";
static NSString *unityAdsViewDidReceiveMemoryWarning = @"VIEW_CONTROLLER_DID_RECEIVE_MEMORY_WARNING";

NSString *NSStringFromAdUnitEvent(UnityAdsAdUnitEvent event) {
    switch (event) {
        case kUnityAdsViewControllerInit:
            return unityAdsViewInit;
        case kUnityAdsViewControllerDidLoad:
            return unityAdsViewDidLoad;
        case kUnityAdsViewControllerDidAppear:
            return unityAdsViewDidAppear;
        case kUnityAdsViewControllerWillDisappear:
            return unityAdsViewWillDisappear;
        case kUnityAdsViewControllerDidDisappear:
            return unityAdsViewDidDisappear;
        case kUnityAdsViewControllerDidReceiveMemoryWarning:
            return unityAdsViewDidReceiveMemoryWarning;
    }
}