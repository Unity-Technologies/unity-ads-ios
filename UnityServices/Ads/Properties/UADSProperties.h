#import "UnityAdsDelegate.h"

extern int const UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT;

@interface UADSProperties : NSObject

+ (void)addDelegate:(id<UnityAdsDelegate>)delegate;
+ (NSOrderedSet<id<UnityAdsDelegate>> *)getDelegates;
+ (void)removeDelegate:(id<UnityAdsDelegate>)delegate;
+ (void)setShowTimeout:(int)timeout;
+ (int)getShowTimeout;

@end
