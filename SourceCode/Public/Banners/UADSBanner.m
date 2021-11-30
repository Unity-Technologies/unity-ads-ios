#import "UADSBannerAdRefreshView.h"
#import "USRVClientProperties.h"
#import "UADSBannerWrapperView.h"

const CGFloat UADSBannerSizeLeaderboardWidth = 728.0f;
const CGFloat UADSBannerSizeLeaderboardHeight = 90.0f;
const CGFloat UADSBannerSizeIABStandardWidth = 468.0f;
const CGFloat UADSBannerSizeIABStandardHeight = 60.0f;
const CGFloat UADSBannerSizeStandardWidth = 320.0f;
const CGFloat UADSBannerSizeStandardHeight = 50.0f;

typedef NS_ENUM (NSInteger, UADSBannerSize) {
    UADSBannerSizeStandard,     // width: 320.0f, height: 50.0f
    UADSBannerSizeLeaderboard,     // width: 728.0f, height: 90.0f
    UADSBannerSizeIABStandard,     // width: 468.0f, height: 60.0f
    UADSBannerSizeDynamic     // the best fitting size from above will be used
};


@interface UnityAdsBanner () <UADSBannerAdRefreshViewDelegate>

@property (nonatomic, weak, readwrite, nullable) id <UnityAdsBannerDelegate> unityAdsBannerDelegate;
@property (nonatomic, assign) UnityAdsBannerPosition currentBannerPosition;
@property (nonatomic, strong) UADSBannerWrapperView *currentBannerView;

@end

@implementation UnityAdsBanner

+ (instancetype)sharedInstance {
    static UnityAdsBanner *unityAdsBanner;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        unityAdsBanner = [[UnityAdsBanner alloc] init];
    });
    return unityAdsBanner;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _currentBannerPosition = kUnityAdsBannerPositionNone;
    }

    return self;
}

- (void)loadBanner: (NSString *)placementId {
    // create banner on main thread
    __weak UnityAdsBanner *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            if (weakSelf.currentBannerView) {
                [weakSelf sendError: @"A Banner is already in use, please call destroy before loading another banner!"];
            } else {
                CGSize size = CGSizeMake(UADSBannerSizeStandardWidth, UADSBannerSizeStandardHeight);
                UADSBannerAdRefreshView *bannerAdRefreshView = [[UADSBannerAdRefreshView alloc] initWithPlacementId: placementId
                                                                                                               size: size];
                UADSBannerWrapperView *bannerWrapperView = [[UADSBannerWrapperView alloc] initWithBannerAdRefreshView: bannerAdRefreshView
                                                                                                       bannerPosition: weakSelf.currentBannerPosition];
                weakSelf.currentBannerView = bannerWrapperView;
                bannerAdRefreshView.delegate = weakSelf;
                [bannerAdRefreshView load];
            }
        }
    });
} /* loadBanner */

- (void)destroy {
    if (self.currentBannerView) {
        UADSBannerWrapperView *bannerWrapperView = self.currentBannerView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [bannerWrapperView removeFromSuperview];
        });
    }

    self.currentBannerView = nil;
}

// MARK UADSBannerAdRefreshViewDelegate

- (void)unityAdsRefreshBannerDidLoad: (UADSBannerAdRefreshView *)bannerAdRefreshView {
    __weak UnityAdsBanner *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.unityAdsBannerDelegate && [weakSelf.unityAdsBannerDelegate respondsToSelector: @selector(unityAdsBannerDidLoad:view:)]) {
            [weakSelf.unityAdsBannerDelegate unityAdsBannerDidLoad: bannerAdRefreshView.placementId
                                                              view: weakSelf.currentBannerView];
        }
    });
}

- (void)unityAdsRefreshBannerDidNoFill: (UADSBannerAdRefreshView *)bannerAdRefreshView {
    // Required method by UADSBannerAdRefreshViewDelegate but behavior does not exist in legacy
    // do nothing
}

- (void)unityAdsRefreshBannerDidShow: (UADSBannerAdRefreshView *)bannerAdRefreshView {
    __weak UnityAdsBanner *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.unityAdsBannerDelegate && [weakSelf.unityAdsBannerDelegate respondsToSelector: @selector(unityAdsBannerDidShow:)]) {
            [weakSelf.unityAdsBannerDelegate unityAdsBannerDidShow: bannerAdRefreshView.placementId];
        }
    });
}

- (void)unityAdsRefreshBannerDidHide: (UADSBannerAdRefreshView *)bannerAdRefreshView {
    __weak UnityAdsBanner *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.unityAdsBannerDelegate && [weakSelf.unityAdsBannerDelegate respondsToSelector: @selector(unityAdsBannerDidHide:)]) {
            [weakSelf.unityAdsBannerDelegate unityAdsBannerDidHide: bannerAdRefreshView.placementId];
        }
    });
}

- (void)unityAdsRefreshBannerDidClick: (UADSBannerAdRefreshView *)bannerAdRefreshView {
    __weak UnityAdsBanner *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.unityAdsBannerDelegate && [weakSelf.unityAdsBannerDelegate respondsToSelector: @selector(unityAdsBannerDidClick:)]) {
            [weakSelf.unityAdsBannerDelegate unityAdsBannerDidClick: bannerAdRefreshView.placementId];
        }
    });
}

- (void)unityAdsRefreshBannerDidError: (UADSBannerAdRefreshView *)bannerAdRefreshView message: (NSString *)message {
    [self sendError: message];
}

- (void)sendError: (NSString *)message {
    __weak UnityAdsBanner *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.unityAdsBannerDelegate && [weakSelf.unityAdsBannerDelegate respondsToSelector: @selector(unityAdsBannerDidError:)]) {
            [weakSelf.unityAdsBannerDelegate unityAdsBannerDidError: message];
        }
    });
}

- (UADSBannerSize)UADSBannerSizeFromDynamic: (UADSBannerSize)size {
    if (size == UADSBannerSizeDynamic) {
        CGSize mainScreenSize;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;

        if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            mainScreenSize = CGSizeMake(screenSize.height, screenSize.width);
        } else {
            mainScreenSize = screenSize;
        }

        if (mainScreenSize.width >= UADSBannerSizeLeaderboardWidth) {
            return UADSBannerSizeLeaderboard;
        } else if (mainScreenSize.width >= UADSBannerSizeIABStandardWidth) {
            return UADSBannerSizeIABStandard;
        } else {
            return UADSBannerSizeStandard;
        }
    } else {
        return size;
    }
} /* UADSBannerSizeFromDynamic */

- (CGFloat)HeightFromUADSBannerSize: (UADSBannerSize)size {
    UADSBannerSize finalSize = [self UADSBannerSizeFromDynamic: size];

    switch (finalSize) {
        case UADSBannerSizeStandard:
            return UADSBannerSizeStandardHeight;

        case UADSBannerSizeLeaderboard:
            return UADSBannerSizeLeaderboardHeight;

        case UADSBannerSizeIABStandard:
            return UADSBannerSizeIABStandardHeight;

        default:
            return UADSBannerSizeStandardHeight;
    }
}

- (CGFloat)WidthFromDynamicBannerSize: (UADSBannerSize)size {
    UADSBannerSize finalSize = [self UADSBannerSizeFromDynamic: size];

    switch (finalSize) {
        case UADSBannerSizeStandard:
            return UADSBannerSizeStandardWidth;

        case UADSBannerSizeLeaderboard:
            return UADSBannerSizeLeaderboardWidth;

        case UADSBannerSizeIABStandard:
            return UADSBannerSizeIABStandardWidth;

        default:
            return UADSBannerSizeStandardWidth;
    }
}

// MARK Public Methods
+ (void)loadBanner: (nonnull NSString *)placementId {
    [[UnityAdsBanner sharedInstance] loadBanner: placementId];
}

+ (void)destroy {
    [[UnityAdsBanner sharedInstance] destroy];
}

+ (void)setBannerPosition: (UnityAdsBannerPosition)bannerPosition {
    [UnityAdsBanner sharedInstance].currentBannerPosition = bannerPosition;
}

+ (id <UnityAdsBannerDelegate>)getDelegate {
    return [UnityAdsBanner sharedInstance].unityAdsBannerDelegate;
}

+ (void)setDelegate: (id <UnityAdsBannerDelegate>)delegate {
    [UnityAdsBanner sharedInstance].unityAdsBannerDelegate = delegate;
}

@end
