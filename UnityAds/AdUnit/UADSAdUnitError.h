#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsAdUnitError) {
    kUnityAdsAdUnitNull,
    kUnityAdsAdUnitNoRotationZ,
    kUnityAdsAdUnitUnknownView,
    kUnityAdsAdUnitHostViewControllerNull
};

NSString *NSStringFromAdUnitError(UnityAdsAdUnitError);

