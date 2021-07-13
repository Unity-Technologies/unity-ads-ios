#import "UADSBannerAdRefreshView.h"
#import "UADSBannerRefreshInfo.h"
#import "UADSBannerView.h"

@interface UADSBannerRefreshBlock : NSObject
- (void)block;
@end

@interface UADSBannerRefreshBlock ()

@property (nonatomic, copy) void (^ refreshBlock)(void);

@end

@implementation UADSBannerRefreshBlock

- (instancetype)initWithBanner: (void (^)(void))refreshBlock {
    self = [super init];

    if (self) {
        _refreshBlock = refreshBlock;
    }

    return self;
}

- (void)block {
    if (_refreshBlock) {
        _refreshBlock();
    }
}

@end

@interface UADSBannerAdRefreshView () <UADSBannerViewDelegate>

@property (nonatomic, strong) UADSBannerView *bannerView;
@property (nonatomic, assign) BOOL isLoadCalled;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate *timerFireDate;
@property (nonatomic, assign) NSTimeInterval refreshRate;

@end

@implementation UADSBannerAdRefreshView

// MARK : Public

- (instancetype)initWithPlacementId: (NSString *)placementId size: (CGSize)size {
    self = [super init];

    if (self) {
        _placementId = placementId;
        _size = size;
        _isLoadCalled = NO;
        _viewId = [NSUUID UUID].UUIDString;
        _refreshRate = 30; // default refresh time is 30s
        _bannerView = [[UADSBannerView alloc] initWithPlacementId: placementId
                                                             size: size];
        _bannerView.delegate = self;
        [self constructView];
    }

    return self;
}

- (void)constructView {
    _bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: _bannerView];

    NSDictionary *views = @{
        @"bannerView": _bannerView
    };

    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[bannerView]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: views]];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[bannerView]|"
                                                                  options: 0
                                                                  metrics: nil
                                                                    views: views]];
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
    }

    if (self.bannerView) {
        self.bannerView.delegate = nil;
        self.bannerView = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)load {
    if (!self.isLoadCalled) {
        self.isLoadCalled = YES;
        [self reload];
        // reload every x seconds
        NSNumber *refreshRate = [[UADSBannerRefreshInfo sharedInstance] getRefreshRateForPlacementId: self.placementId];

        if (refreshRate != nil) {
            self.refreshRate = [refreshRate doubleValue];
        }

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(willResignActive)
                                                     name: UIApplicationWillResignActiveNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didBecomeActive)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didEnterBackground)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(willEnterForeground)
                                                     name: UIApplicationWillEnterForegroundNotification
                                                   object: nil];
        [self createNewRefreshTimer];
    }
} /* load */

// MARK : Private

- (void)reload {
    [self.bannerView load];
}

- (void)createNewRefreshTimer {
    NSDate *fireDate = [NSDate dateWithTimeIntervalSince1970: [NSDate date].timeIntervalSince1970 + self.refreshRate];

    [self createNewTimer: fireDate];
}

- (void)createNewTimer: (NSDate *)fireDate {
    if (self.timer) {
        [self.timer invalidate];
    }

    __weak UADSBannerAdRefreshView *weakSelf = self;
    UADSBannerRefreshBlock *bannerRefreshBlock = [[UADSBannerRefreshBlock alloc] initWithBanner: ^{
        if (weakSelf && weakSelf.timer) {
            if (weakSelf.timer.isValid) {
                [weakSelf reload];
            } else {
                [weakSelf.timer invalidate];
            }
        }
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval: self.refreshRate
                                                  target: bannerRefreshBlock
                                                selector: @selector(block)
                                                userInfo: nil
                                                 repeats: YES];
    self.timer.fireDate = fireDate;
} /* createNewTimer */

- (void)didEnterBackground {
    [self stopTimer];
}

- (void)willEnterForeground {
    [self startTimer];
}

- (void)willResignActive {
    [self stopTimer];
}

- (void)didBecomeActive {
    [self startTimer];
}

- (void)stopTimer {
    if (self.timer && self.timer.valid) {
        self.timerFireDate = self.timer.fireDate;
        [self.timer invalidate];
    }
}

- (void)startTimer {
    if (!self.timer || !self.timer.valid) {
        NSDate *currentDate = [[NSDate alloc] init];

        if (self.timerFireDate && currentDate.timeIntervalSince1970 < self.timerFireDate.timeIntervalSince1970) {
            [self createNewTimer: self.timerFireDate];
        } else {
            [self reload]; // if we are past the date do a reload and start the timer new
            [self createNewRefreshTimer];
        }
    }
}

// MARK : UADSBannerViewDelegate

- (void)bannerViewDidLoad: (UADSBannerView *)bannerView {
    if (self.delegate && [self.delegate respondsToSelector: @selector(unityAdsRefreshBannerDidLoad:)]) {
        __weak UADSBannerAdRefreshView *weakSelf = self;
        [self.delegate unityAdsRefreshBannerDidLoad: weakSelf];
    }
}

- (void)bannerViewDidClick: (UADSBannerView *)bannerView {
    if (self.delegate && [self.delegate respondsToSelector: @selector(unityAdsRefreshBannerDidClick:)]) {
        __weak UADSBannerAdRefreshView *weakSelf = self;
        [self.delegate unityAdsRefreshBannerDidClick: weakSelf];
    }
}

- (void)bannerViewDidError: (UADSBannerView *)bannerView error: (UADSBannerError *)error {
    if (self.delegate && [self.delegate respondsToSelector: @selector(unityAdsRefreshBannerDidError:message:)]) {
        __weak UADSBannerAdRefreshView *weakSelf = self;
        [self.delegate unityAdsRefreshBannerDidError: weakSelf
                                             message: error.localizedDescription];
    }
}

@end
