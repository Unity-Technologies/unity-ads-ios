#import <UIKit/UIKit.h>
#import "UADSAVPlayer.h"
#import "UADSVideoView.h"
#import "UADSWebPlayerView.h"
#import "UADSARView.h"
#import "UADSAdUnitViewHandler.h"

@interface UADSViewController : UIViewController

@property (nonatomic, strong) NSArray<NSString*> *currentViews;
@property (nonatomic, assign) int supportedOrientations;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL autorotate;
@property (nonatomic, assign) BOOL transparent;
@property (nonatomic, assign) BOOL homeIndicatorAutoHidden;

- (instancetype)initWithViews:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(BOOL)statusBarHidden shouldAutorotate:(BOOL)shouldAutorotate isTransparent:(BOOL)isTransparent homeIndicatorAutoHidden:(BOOL)homeIndicatorAutoHidden;
- (void)setViews:(NSArray<NSString*>*)views;
- (void)setTransform:(float)transform;
- (void)setViewFrame:(NSString *)view x:(int)x y:(int)y width:(int)width height:(int)height;
- (BOOL)prefersHomeIndicatorAutoHidden;
- (UADSAdUnitViewHandler *)getViewHandler:(NSString *)viewName;
@end
