#import "UnityAds.h"

@interface UADSProperties : NSObject

+ (void)setDelegate:(id<UnityAdsDelegate>)delegate;
+ (id<UnityAdsDelegate>)getDelegate;
+ (void)setShowTimeout:(int)timeout;
+ (int)getShowTimeout;

@end
