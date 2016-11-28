#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsAdUnitError) {
    kUnityAdsViewControllerNull,
    kUnityAdsViewControllerNoRotationZ,
    kUnityAdsViewControllerUnknownView,
    kUnityAdsViewControllerTargetViewNull
};

NSString *NSStringFromAdUnitError(UnityAdsAdUnitError);

