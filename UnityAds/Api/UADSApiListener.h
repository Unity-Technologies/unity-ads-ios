#import "UnityAds.h"

typedef NS_ENUM(NSInteger, UnityAdsListenerError) {
    kUnityAdsCouldNotFindSelector,
    kUnityAdsDelegateNull
};

UnityAdsFinishState UnityAdsFinishStateFromNSString (NSString* state);

NSString *NSStringFromListenerError(UnityAdsListenerError error) {
    switch (error) {
        case kUnityAdsCouldNotFindSelector:
            return @"COULD NOT FIND SELECTOR";
        case kUnityAdsDelegateNull:
            return @"DELEGATE IS NULL";
    }
}

@interface UADSApiListener : NSObject
@end