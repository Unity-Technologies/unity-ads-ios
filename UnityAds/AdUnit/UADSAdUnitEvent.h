#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsAdUnitEvent) {
    kUnityAdsViewControllerInit,
    kUnityAdsViewControllerDidLoad,
    kUnityAdsViewControllerDidAppear,
    kUnityAdsViewControllerWillDisappear,
    kUnityAdsViewControllerDidDisappear,
    kUnityAdsViewControllerDidReceiveMemoryWarning
};

NSString *NSStringFromAdUnitEvent(UnityAdsAdUnitEvent);
