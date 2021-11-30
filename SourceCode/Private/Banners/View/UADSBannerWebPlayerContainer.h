#import <UIKit/UIKit.h>
#import "UADSWebPlayerView.h"

@interface UADSBannerWebPlayerContainer : UIView

@property (nonatomic, retain) UADSWebPlayerView *webPlayer;

- (instancetype)initWithBannerAdId: (NSString *)bannerAdId webPlayerSettings: (NSDictionary *)webPlayerSettings webPlayerEventSettings: (NSDictionary *)webPlayerEventSettings size: (CGSize)size;

@end

@protocol UADSBannerWebPlayerContainerDelegate

- (void)setBannerWebPlayerContainer: (UADSBannerWebPlayerContainer *)bannerWebPlayerContainer;

- (UADSBannerWebPlayerContainer *)getBannerWebPlayerContainer;

@end
