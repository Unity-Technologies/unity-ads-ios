#import "UADSBannerWebPlayerContainer.h"
#import "UADSBannerEvent.h"
#import "UADSWebPlayerViewManager.h"
#import "USRVBannerBridge.h"

@interface UADSBannerWebPlayerContainer ()

@property (nonatomic, strong) NSString *bannerAdId;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;

@end

@implementation UADSBannerWebPlayerContainer

- (instancetype)initWithBannerAdId: (NSString *)bannerAdId webPlayerSettings: (NSDictionary *)webPlayerSettings webPlayerEventSettings: (NSDictionary *)webPlayerEventSettings size: (CGSize)size {
    self = [super initWithFrame: CGRectZero];

    if (self) {
        _bannerAdId = bannerAdId;
        _size = size;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.webPlayer = [[UADSWebPlayerView alloc] initWithFrame: CGRectZero
                                                           viewId: bannerAdId
                                                webPlayerSettings: webPlayerSettings];
        [self.webPlayer setEventSettings: webPlayerEventSettings];
        [self addObserver: self
               forKeyPath: @"frame"
                  options: NSKeyValueObservingOptionNew
                  context: nil];
        [self addObserver: self
               forKeyPath: @"hidden"
                  options: NSKeyValueObservingOptionNew
                  context: nil];
        [self addObserver: self
               forKeyPath: @"alpha"
                  options: NSKeyValueObservingOptionNew
                  context: nil];
        [[UADSWebPlayerViewManager sharedInstance] addWebPlayerView: self.webPlayer
                                                             viewId: bannerAdId];
        [self constructView];
    }

    return self;
} /* initWithBannerAdId */

- (void)constructView {
    self.webPlayer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.webPlayer];
    NSDictionary *views = @{
        @"webPlayer": self.webPlayer
    };

    self.heightConstraint = [NSLayoutConstraint constraintWithItem: self
                                                         attribute: NSLayoutAttributeHeight
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: nil
                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                        multiplier: 1.0
                                                          constant: self.size.height];
    self.widthConstraint = [NSLayoutConstraint constraintWithItem: self
                                                        attribute: NSLayoutAttributeWidth
                                                        relatedBy: NSLayoutRelationEqual
                                                           toItem: nil
                                                        attribute: NSLayoutAttributeNotAnAttribute
                                                       multiplier: 1.0
                                                         constant: self.size.width];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[webPlayer]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: views]];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[webPlayer]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: views]];
    [self addConstraint: self.heightConstraint];
    [self addConstraint: self.widthConstraint];
} /* constructView */

- (void)dealloc {
    [self.webPlayer removeFromSuperview];
    [[UADSWebPlayerViewManager sharedInstance] removeWebPlayerViewWithViewId: _bannerAdId];
    [self.webPlayer destroy];
    self.webPlayer = nil;
    [self removeObserver: self
              forKeyPath: @"frame"
                 context: nil];
    [self removeObserver: self
              forKeyPath: @"hidden"
                 context: nil];
    [self removeObserver: self
              forKeyPath: @"alpha"
                 context: nil];
}

- (void)willMoveToWindow: (UIWindow *)newWindow {
    [super willMoveToWindow: newWindow];

    if (newWindow == nil) {
        [USRVBannerBridge bannerDidDetachWithBannerId: self.bannerAdId];
    } else {
        [USRVBannerBridge bannerDidAttachWithBannerId: self.bannerAdId];
    }
}

- (void)observeValueForKeyPath: (NSString *)keyPath ofObject: (id)object change: (NSDictionary *)change context: (void *)context {
    if (object == self) {
        if ([keyPath isEqualToString: @"alpha"] || [keyPath isEqualToString: @"frame"]) {
            self.webPlayer.frame = self.frame;
            CGRect frame = self.frame;
            [USRVBannerBridge bannerDidResizeWithBannerId: self.bannerAdId
                                                    frame: frame
                                                    alpha: self.alpha];
        } else if ([keyPath isEqualToString: @"hidden"]) {
            if (self.hidden) {
                [USRVBannerBridge bannerVisibilityChangedWithBannerId: self.bannerAdId
                                                     bannerVisibility: UADSBannerVisibilityGone];
            } else {
                [USRVBannerBridge bannerVisibilityChangedWithBannerId: self.bannerAdId
                                                     bannerVisibility: UADSBannerVisibilityVisible];
            }
        }
    }
}

@end
