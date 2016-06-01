#import "UADSWebViewCallback.h"
#import "UnityAds.h"

@interface UADSApiPlacement : NSObject

+ (void)WebViewExposed_setDefaultPlacement:(NSString *)placement webViewCallback:(UADSWebViewCallback *)callback;

+ (void)WebViewExposed_setPlacementState:(NSString *)placement placementState:(NSString *)placementState webViewCallback:(UADSWebViewCallback *)callback;

+ (BOOL)isReady:(NSString *)placement;

+ (BOOL)isReady;

+ (NSString *)getDefaultPlacement;

+ (UnityAdsPlacementState)getPlacementState;

+ (UnityAdsPlacementState)getPlacementState: (NSString *)placement;

+ (void)reset;

@end

