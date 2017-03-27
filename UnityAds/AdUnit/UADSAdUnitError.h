#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsAdUnitError) {
    kUnityAdsAdUnitNull,
    kUnityAdsAdUnitNoRotationZ,
    kUnityAdsAdUnitUnknownView,
};

NSString *NSStringFromAdUnitError(UnityAdsAdUnitError);

