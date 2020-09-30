#import "UnityAdsDelegate.h"

extern int const UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT;

@interface UADSProperties : NSObject

+ (void)setDelegate:(id <UnityAdsDelegate>)delegate;
+ (__nullable id <UnityAdsDelegate>)getDelegate;
+ (void)addDelegate:(id<UnityAdsDelegate>)delegate;
+ (NSOrderedSet<id<UnityAdsDelegate>> *)getDelegates;
+ (void)removeDelegate:(id<UnityAdsDelegate>)delegate;

@end
