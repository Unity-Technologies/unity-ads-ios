#import "UADSBannerViewManager.h"

@interface UADSBannerViewWrapper : NSObject

@property(nonatomic, weak) UADSBannerView *bannerView;

@end

@implementation UADSBannerViewWrapper

- (instancetype)initWithBannerView:(UADSBannerView *)bannerView {
    self = [super init];
    if (self) {
        _bannerView = bannerView;
    }
    return self;
}

@end

@interface UADSBannerViewManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, UADSBannerViewWrapper *> *bannerViews;

@end

@implementation UADSBannerViewManager

// Public

+ (instancetype)sharedInstance {
    static UADSBannerViewManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UADSBannerViewManager alloc] init];
    });
    return sharedInstance;
}

- (void)addBannerView:(UADSBannerView *)bannerView bannerAdId:(NSString *)bannerAdId {
    @synchronized (self) {
        UADSBannerViewWrapper *wrapper = [[UADSBannerViewWrapper alloc] initWithBannerView:bannerView];
        [self.bannerViews setObject:wrapper forKey:bannerAdId];
    }
}

- (UADSBannerView *_Nullable)getBannerViewWithBannerAdId:(NSString *)bannerAdId {
    @synchronized (self) {
        UADSBannerViewWrapper *wrapper = [self.bannerViews objectForKey:bannerAdId];
        if (wrapper) {
            return wrapper.bannerView;
        } else {
            return nil;
        }
    }
}

- (void)removeBannerViewWithBannerAdId:(NSString *)bannerAdId {
    @synchronized (self) {
        [self.bannerViews removeObjectForKey:bannerAdId];
    }
}

- (void)triggerBannerDidLoad:(NSString *)bannerAdId {
    UADSBannerView *bannerView = [self getBannerViewWithBannerAdId:bannerAdId];
    if (bannerView) {
        id <UADSBannerViewDelegate> bannerDelegate = [bannerView delegate];
        if (bannerDelegate && [bannerDelegate respondsToSelector:@selector(bannerViewDidLoad:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak UADSBannerView *weakBanner = bannerView;
                [bannerDelegate bannerViewDidLoad:weakBanner];
            });
        }
    }
}

- (void)triggerBannerDidClick:(NSString *)bannerAdId {
    UADSBannerView *bannerView = [self getBannerViewWithBannerAdId:bannerAdId];
    if (bannerView) {
        id <UADSBannerViewDelegate> bannerDelegate = [bannerView delegate];
        if (bannerDelegate && [bannerDelegate respondsToSelector:@selector(bannerViewDidClick:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak UADSBannerView *weakBanner = bannerView;
                [bannerDelegate bannerViewDidClick:weakBanner];
            });
        }
    }
}

- (void)triggerBannerDidLeaveApplication:(NSString *)bannerAdId {
    UADSBannerView *bannerView = [self getBannerViewWithBannerAdId:bannerAdId];
    if (bannerView) {
        id <UADSBannerViewDelegate> bannerDelegate = [bannerView delegate];
        if (bannerDelegate && [bannerDelegate respondsToSelector:@selector(bannerViewDidLeaveApplication:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak UADSBannerView *weakBanner = bannerView;
                [bannerDelegate bannerViewDidLeaveApplication:weakBanner];
            });
        }
    }
}

- (void)triggerBannerDidError:(NSString *)bannerAdId error:(UADSBannerError *)error {
    UADSBannerView *bannerView = [self getBannerViewWithBannerAdId:bannerAdId];
    if (bannerView) {
        id <UADSBannerViewDelegate> bannerDelegate = [bannerView delegate];
        if (bannerDelegate && [bannerDelegate respondsToSelector:@selector(bannerViewDidError:error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak UADSBannerView *weakBanner = bannerView;
                [bannerDelegate bannerViewDidError:weakBanner error:error];
            });
        }
    }
}

// Private

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bannerViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
