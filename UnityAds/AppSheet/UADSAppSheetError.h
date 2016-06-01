#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsAppSheetError) {
    kUnityAdsAppSheetErrorAlreadyPreparing,
    kUnityAdsAppSheetErrorAlreadyPresenting,
    kUnityAdsAppSheetErrorNotFound,
    kUnityAdsAppSheetErrorNoAppSheetFound,
    kUnityAdsAppSheetErrorTimeout
    
};

NSString *NSStringFromAppSheetError(UnityAdsAppSheetError);
