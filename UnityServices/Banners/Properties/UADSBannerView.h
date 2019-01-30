#import <UIKit/UIKit.h>
#import "UADSWebPlayerView.h"
#import "UADSBanner.h"

@interface UADSBannerView : UIView
@property(nonatomic) CGSize adSize;
@property(nonatomic, retain) UADSWebPlayerView *webPlayer;
@property(nonatomic) UnityAdsBannerPosition position;
@property(nonatomic) NSArray *views;

-(void)setViewFrame:(NSString *)viewName x:(float)x y:(float)y width:(float)width height:(float)height;

-(void)setViews:(NSArray *)views;

-(void)close;

+(UADSBannerView *)getOrCreateInstance;

+(UADSBannerView *)getInstance;

+(void)destroyInstance;

+(void)setWebPlayerSettings:(NSDictionary *)newSettings;

+(void)setWebPlayerEventSettings:(NSDictionary *)newSettings;

@end
