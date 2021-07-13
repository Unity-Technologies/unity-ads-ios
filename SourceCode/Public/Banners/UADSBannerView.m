#import "UADSBannerView.h"
#import "USRVBannerBridge.h"
#import "UADSBannerWebPlayerContainer.h"
#import "UADSBannerViewManager.h"
#import "USRVSdkProperties.h"
#import "USRVInitializationNotificationCenter.h"

@interface UADSBannerView () <USRVInitializationDelegate>

@property (nonatomic, strong) NSString *viewId;
@property (nonatomic, strong) UADSBannerWebPlayerContainer *bannerWebPlayerContainer;

@end

@implementation UADSBannerView

// MARK : Public methods

- (instancetype)initWithPlacementId: (NSString *)placementId size: (CGSize)size {
    self = [super init];

    if (self) {
        _placementId = placementId;
        _size = size;
        _viewId = [NSUUID UUID].UUIDString;
        [[UADSBannerViewManager sharedInstance] addBannerView: self
                                                   bannerAdId: self.viewId];
        [self setupConstraints];
    }

    return self;
}

- (void)load {
    if ([USRVSdkProperties isInitialized]) {
        [self bridgeLoad];
    } else {
        __weak UADSBannerView *weakSelf = self;
        [[USRVInitializationNotificationCenter sharedInstance] addDelegate: weakSelf];
    }
}

// MARK : Private methods

- (void)bridgeLoad {
    [USRVBannerBridge loadBannerPlacement: self.placementId
                               bannerAdId: self.viewId
                                     size: self.size];
}

- (void)setBannerWebPlayerContainer: (UADSBannerWebPlayerContainer *)bannerWebPlayerContainer {
    __weak UADSBannerView *weakSelf = self;
    __block UADSBannerWebPlayerContainer *bannerToRemove = _bannerWebPlayerContainer;

    _bannerWebPlayerContainer = bannerWebPlayerContainer;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            [bannerToRemove removeFromSuperview];
            bannerWebPlayerContainer.translatesAutoresizingMaskIntoConstraints = NO;
            [weakSelf addSubview: bannerWebPlayerContainer];
            [weakSelf addConstraint: [NSLayoutConstraint constraintWithItem: bannerWebPlayerContainer
                                                                  attribute: NSLayoutAttributeCenterX
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: weakSelf
                                                                  attribute: NSLayoutAttributeCenterX
                                                                 multiplier: 1.0
                                                                   constant: 0]];
            [weakSelf addConstraint: [NSLayoutConstraint constraintWithItem: bannerWebPlayerContainer
                                                                  attribute: NSLayoutAttributeCenterY
                                                                  relatedBy: NSLayoutRelationEqual
                                                                     toItem: weakSelf
                                                                  attribute: NSLayoutAttributeCenterY
                                                                 multiplier: 1.0
                                                                   constant: 0]];
        }
    });
} /* setBannerWebPlayerContainer */

- (UADSBannerWebPlayerContainer *)getBannerWebPlayerContainer {
    return _bannerWebPlayerContainer;
}

// only call this once
- (void)setupConstraints {
    __weak UADSBannerView *weakSelf = self;
    __block NSDictionary *views = @{
        @"bannerView": self
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = weakSelf.size.height;
        CGFloat width = weakSelf.size.width;
        NSDictionary *metrics = @{
            @"height": [NSNumber numberWithFloat: height],
            @"width": [NSNumber numberWithFloat: width]
        };
        [weakSelf addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:[bannerView(width)]"
                                                                          options: 0
                                                                          metrics: metrics
                                                                            views: views]];
        [weakSelf addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[bannerView(height)]"
                                                                          options: 0
                                                                          metrics: metrics
                                                                            views: views]];
        weakSelf.frame = CGRectMake(0, 0, width, height);
    });
} /* setupConstraints */

- (void)dealloc {
    self.delegate = nil;
    [[UADSBannerViewManager sharedInstance] removeBannerViewWithBannerAdId: self.viewId];
    [[USRVInitializationNotificationCenter sharedInstance] removeDelegate: self];
    [USRVBannerBridge destroyBannerWithId: self.viewId];
}

// MARK : USRVInitializationDelegate

- (void)sdkDidInitialize {
    [[USRVInitializationNotificationCenter sharedInstance] removeDelegate: self];
    [self bridgeLoad];
}

- (void)sdkInitializeFailed: (NSError *)error {
    [[USRVInitializationNotificationCenter sharedInstance] removeDelegate: self];

    if (self.delegate && [self.delegate respondsToSelector: @selector(bannerViewDidError:error:)]) {
        UADSBannerError *error = [[UADSBannerError alloc] initWithCode: UADSBannerErrorCodeNativeError
                                                              userInfo: @{
                                      NSLocalizedDescriptionKey: @"UnityAds failed to initialize! Banner load could not be sent!"
        }];
        __weak UADSBannerView *weakSelf = self;
        [self.delegate bannerViewDidError: weakSelf
                                    error: error];
    }
}

@end
