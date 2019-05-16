#import "UADSBanner.h"

@interface UADSBannerProperties : NSObject
+(id <UnityAdsBannerDelegate>)getDelegate;

+(void)setDelegate:(id <UnityAdsBannerDelegate>)delegate;
@end
