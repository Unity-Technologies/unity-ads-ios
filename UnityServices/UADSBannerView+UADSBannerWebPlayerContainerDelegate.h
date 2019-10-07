#import <Foundation/Foundation.h>
#import "UADSBannerView.h"
#import "UADSBannerWebPlayerContainer.h"

@interface UADSBannerView (UADSBannerWebPlayerContainerDelegate) <UADSBannerWebPlayerContainerDelegate>

-(void)setBannerWebPlayerContainer:(UADSBannerWebPlayerContainer *)bannerWebPlayerContainer;
-(UADSBannerWebPlayerContainer *)getBannerWebPlayerContainer;

@end


