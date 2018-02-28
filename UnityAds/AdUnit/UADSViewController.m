#import "UADSViewController.h"
#import "UADSWebViewApp.h"
#import "UADSAdUnitEvent.h"
#import "UADSWebViewEventCategory.h"
#import "UADSApiWebPlayer.h"
#import "UnityAds.h"
#import <sys/utsname.h>

@interface UADSViewController ()

@end

@implementation UADSViewController

- (instancetype)initWithViews:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(BOOL)statusBarHidden shouldAutorotate:(BOOL)shouldAutorotate isTransparent:(BOOL)isTransparent homeIndicatorAutoHidden:(BOOL)homeIndicatorAutoHidden {
    self = [super init];

    if (self) {
        [self setTransparent:isTransparent];
        [self setCurrentViews:views];
        [self setStatusBarHidden:statusBarHidden];
        [self setSupportedOrientations:[supportedOrientations intValue]];
        [self setAutorotate:shouldAutorotate];
        [self setHomeIndicatorAutoHidden:homeIndicatorAutoHidden];
    }

    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerInit) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAdunit) param1:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[self isTransparent] ? [UIColor clearColor] : [UIColor blackColor]];
    
    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidLoad) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAdunit) param1:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setViews:self.currentViews];

    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidAppear) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAdunit) param1:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setViews:self.currentViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerWillDisappear) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAdunit) param1:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self destroyVideoPlayer];
    [self destroyVideoView];
    [self destroyWebPlayerView];
    [[[UADSWebViewApp getCurrentApp] webView] removeFromSuperview];
    [[UADSWebViewApp getCurrentApp] placeWebViewToBackgroundView];
    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidDisappear) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAdunit) param1:nil];
}

- (void)setViewFrame:(NSString *)view x:(int)x y:(int)y width:(int)width height:(int)height {
    UIView *targetView = NULL;

    if ([view isEqualToString:@"adunit"]) {
        targetView = self.view;
    }
    else if ([view isEqualToString:@"videoplayer"]) {
        targetView = self.videoView;
    }
    else if ([view isEqualToString:@"webview"]) {
        targetView = [[UADSWebViewApp getCurrentApp] webView];
    } else if ([view isEqualToString:@"webplayer"]) {
        targetView = self.webPlayerView;
    }

    if (targetView) {
        [targetView setFrame:CGRectMake(x, y, width, height)];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

- (BOOL)shouldAutorotate {
    return self.autorotate;
}

- (void)setSupportedOrientations:(int)supportedOrientations {
    _supportedOrientations = supportedOrientations;
    [self.view setNeedsLayout];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setTransparent:(BOOL)isTransparent {
    _transparent = isTransparent;
}

- (void)setTransform:(float)transform {
    self.view.transform = CGAffineTransformMakeRotation(transform);
}

- (void)setHomeIndicatorAutoHidden:(BOOL)homeIndicatorAutoHidden {
    _homeIndicatorAutoHidden = homeIndicatorAutoHidden;
    
    SEL setNeedsUpdateOfHomeIndicatorAutoHiddenSelector = NSSelectorFromString(@"setNeedsUpdateOfHomeIndicatorAutoHidden");
    if([self respondsToSelector:setNeedsUpdateOfHomeIndicatorAutoHiddenSelector]) {
        IMP setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorImp = [self methodForSelector:setNeedsUpdateOfHomeIndicatorAutoHiddenSelector];
        if (setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorImp) {
            void (*setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorFunc)(id, SEL) = (void *)setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorImp;
            setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorFunc(self, setNeedsUpdateOfHomeIndicatorAutoHiddenSelector);
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return self.homeIndicatorAutoHidden;
}

- (BOOL)isTransparent {
    return _transparent;
}

- (void)setViews:(NSArray<NSString*>*)views {
    NSMutableArray<NSString*>* actualViews = NULL;

    if (views == NULL) {
        actualViews = [[NSMutableArray alloc] init];
    }
    else {
        actualViews = [[NSMutableArray alloc] init];
        [actualViews addObjectsFromArray:views];
    }
    
    if (!_currentViews) {
        _currentViews = [[NSArray alloc] init];
    }
    
    NSMutableArray<NSString*>* newViews = [[NSMutableArray alloc] init];
    [newViews addObjectsFromArray:actualViews];
    NSMutableArray<NSString*>* removedViews = [[NSMutableArray alloc] init];
    [removedViews addObjectsFromArray:_currentViews];
    [removedViews removeObjectsInArray:newViews];

    for (NSString *view in removedViews) {
        if ([view isEqualToString:@"videoplayer"]) {
            [self destroyVideoPlayer];
            [self destroyVideoView];
        }
        else if ([view isEqualToString:@"webplayer"]) {
            [self destroyWebPlayerView];
        }
        else if ([view isEqualToString:@"webview"]) {
            [[[UADSWebViewApp getCurrentApp] webView] removeFromSuperview];
        }
    }

    for (NSString *view in actualViews) {
        if (view == NULL) {
            continue;
        }
        else if ([view isEqualToString:@"videoplayer"]) {
            [self createVideoView];
            [self createVideoPlayer];
            [self handleViewPlacement:self.videoView];
        }
        else if ([view isEqualToString:@"webplayer"]) {
            [self createWebPlayerView];
            [self handleViewPlacement:self.webPlayerView];
        }
        else if ([view isEqualToString:@"webview"]) {
            if ([UADSWebViewApp getCurrentApp]) {
                [self handleViewPlacement:[[UADSWebViewApp getCurrentApp] webView]];
            }
        }
    }

    _currentViews = [[NSArray alloc] initWithArray:actualViews copyItems:true];
}

- (void)handleViewPlacement:(UIView *)view {
    if ([view superview] && [[view superview] isEqual:self.view]) {
        UADSLogDebug(@"Bringing to front: %@", view);
        [self.view bringSubviewToFront:view];
    }
    else {
        if ([view superview]) {
            [view removeFromSuperview];
        }

        [view setHidden:false];
        [view setCenter:[self.view convertPoint:self.view.center fromView:self.view.superview]];
        [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        UADSLogDebug(@"Adding to view: %@", view);
        [self.view addSubview:view];
    }
    [view setFrame:[self getRect]];
}

- (void)createVideoPlayer {
    if (![self videoPlayer]) {
        AVURLAsset *asset = nil;
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [self setVideoPlayer:[[UADSAVPlayer alloc] initWithPlayerItem:item]];
        [self.videoView setPlayer:self.videoPlayer];
    }
}

- (void)createVideoView {
    if (![self videoView]) {
        [self setVideoView:[[UADSVideoView alloc] initWithFrame:[self getRect]]];
        [self.videoView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    }
}

- (void)destroyVideoView {
    if ([self videoView]) {
        [self.videoView removeFromSuperview];
    }

    self.videoView = NULL;
}

- (void)createWebPlayerView {
    if (![self webPlayerView]) {
        [self setWebPlayerView:[[UADSWebPlayerView alloc] initWithFrame:[self getRect] webPlayerSettings:[UADSApiWebPlayer getWebPlayerSettings]]];
        [[self webPlayerView] setEventSettings:[UADSApiWebPlayer getWebPlayerEventSettings]];
    }
}

- (void)destroyWebPlayerView {
    if ([self webPlayerView]) {
        [self.webPlayerView removeFromSuperview];
    }
    self.webPlayerView = nil;
}

- (void)destroyVideoPlayer {
    if ([self videoPlayer]) {
        [self.videoPlayer stop];
        [self.videoPlayer stopObserving];
    }

    self.videoPlayer = NULL;
}

- (CGRect)getRect {
    CGFloat x = CGRectGetMinX(self.view.bounds);
    CGFloat y = CGRectGetMinY(self.view.bounds);
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    return CGRectMake(x, y, width, height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidReceiveMemoryWarning) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAdunit) param1:nil];
}
@end
