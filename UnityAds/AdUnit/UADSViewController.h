#import <UIKit/UIKit.h>
#import "UADSAVPlayer.h"
#import "UADSVideoView.h"

@interface UADSViewController : UIViewController

@property (nonatomic, strong) UADSAVPlayer *videoPlayer;
@property (nonatomic, strong) UADSVideoView *videoView;
@property (nonatomic, strong) NSArray<NSString*> *currentViews;
@property (nonatomic, assign) int supportedOrientations;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL autorotate;

- (instancetype)initWithViews:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(BOOL)statusBarHidden shouldAutorotate:(BOOL)shouldAutorotate;
- (void)setViews:(NSArray<NSString*>*)views;
- (void)setTransform:(float)transform;
- (void)setViewFrame:(NSString *)view x:(int)x y:(int)y width:(int)width height:(int)height;

@end
