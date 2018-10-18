#import "UADSBannerView.h"
#import "UADSBannerEvent.h"
#import "USRVWebViewApp.h"
#import "USRVDeviceLog.h"
#import "USRVWebViewEventCategory.h"
#import "UADSBannerEvent.h"

@implementation UADSBannerView

static NSDictionary *webPlayerSettings;
static NSDictionary *webPlayerEventSettings;
static UADSBannerView *instance;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.translatesAutoresizingMaskIntoConstraints = false;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webPlayer = [[UADSWebPlayerView alloc] initWithFrame:frame viewId:@"bannerplayer" webPlayerSettings:webPlayerSettings];
    [self.webPlayer setEventSettings:webPlayerEventSettings];
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame" context:nil];
    [self removeObserver:self forKeyPath:@"hidden" context:nil];
    [self removeObserver:self forKeyPath:@"alpha" context:nil];
}

-(void)setViews:(NSArray *)views {
    NSMutableArray *viewsToAdd = [NSMutableArray arrayWithArray:views];
    NSMutableArray *viewsToRemove = [[NSMutableArray alloc] init];

    if (_views) {
        [viewsToRemove addObjectsFromArray:self.views];
        [viewsToRemove removeObjectsInArray:views];
        [viewsToAdd removeObjectsInArray:views];
    }
    _views = views;
    for (NSString *view in views) {
        [self addView:view];
    }
}

-(void)addView:(NSString *)viewName {
    UIView *view = [self getViewByName:viewName];
    if (view && view != self) {
        [view setFrame:[self getRect]];
        [self addSubview:view];
    }
}

-(void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];

    UnityAdsBannerEvent event = newWindow == nil ? kUnityAdsBannerEventDetached : kUnityAdsBannerEventAttached;
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:NSStringFromBannerEvent(event) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) param1:nil];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (self.superview) {
        CGPoint point = [self getPointForPosition];
        CGRect frame = self.frame;
        [self setFrame:CGRectMake(point.x, point.y, frame.size.width, frame.size.height)];
    }
}

-(CGPoint)getPointForPosition {
    UIView *parent = self.superview;
    UIEdgeInsets insets = [self getSafeInsetsForContainer:parent];
    CGSize parentSize = parent.frame.size;
    CGSize selfSize = self.adSize;

    switch (self.position) {
        case kUnityAdsBannerPositionTopLeft:
            return CGPointMake(insets.left, insets.top);
        case kUnityAdsBannerPositionTopRight:
            return CGPointMake((parentSize.width - selfSize.width - insets.right), insets.top);
        case kUnityAdsBannerPositionTopCenter:
            return CGPointMake((parentSize.width / 2) - (selfSize.width / 2), insets.top);
        case kUnityAdsBannerPositionBottomLeft:
            return CGPointMake(insets.left, (parentSize.height - selfSize.height) - insets.bottom);
        case kUnityAdsBannerPositionBottomRight:
            return CGPointMake((parentSize.width - selfSize.width - insets.right), (parentSize.height - selfSize.height) - insets.bottom);
        case kUnityAdsBannerPositionBottomCenter:
            return CGPointMake((parentSize.width / 2) - (selfSize.width / 2), (parentSize.height - selfSize.height) - insets.bottom);
        case kUnityAdsBannerPositionCenter:
            return CGPointMake((parentSize.width / 2) - (selfSize.width / 2), (parentSize.height / 2) - (selfSize.height / 2));
        case kUnityAdsBannerPositionNone:
        default:
            return CGPointZero;
    }
}

-(UIEdgeInsets)getSafeInsetsForContainer:(UIView *)container {
    // Safe insets is only for iOS 11
    SEL safeAreaSelector = @selector(safeAreaInsets);
    if ([container respondsToSelector:safeAreaSelector]) {
        NSMethodSignature *sig = [container methodSignatureForSelector:safeAreaSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:container];
        [invocation setSelector:safeAreaSelector];
        [invocation invoke];
        UIEdgeInsets insets;
        [invocation getReturnValue:&insets];
        return insets;
    }
    // iOS 8 can use layout margins.
    SEL layoutMarginsSelector = @selector(layoutMargins);
    if ([container respondsToSelector:layoutMarginsSelector]) {
        NSMethodSignature *sig = [container methodSignatureForSelector:layoutMarginsSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:container];
        [invocation setSelector:layoutMarginsSelector];
        [invocation invoke];
        UIEdgeInsets insets;
        [invocation getReturnValue:&insets];
        return insets;
    }
    // iOS 7
    return UIEdgeInsetsZero;
}

-(void)close {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}

-(CGRect)getRect {
    CGFloat x = CGRectGetMinX(self.bounds);
    CGFloat y = CGRectGetMinY(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);

    return CGRectMake(x, y, width, height);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        if ([keyPath isEqualToString:@"alpha"] || [keyPath isEqualToString:@"frame"]) {
            CGRect frame = self.frame;
            [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromBannerEvent(kUnityAdsBannerEventResized) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) param1:
                    [NSNumber numberWithFloat:frame.origin.x],
                    [NSNumber numberWithFloat:frame.origin.y],
                    [NSNumber numberWithFloat:frame.size.width],
                    [NSNumber numberWithFloat:frame.size.height],
                    [NSNumber numberWithFloat:self.alpha],
                            nil];
        } else if ([keyPath isEqualToString:@"hidden"]) {
            if (self.hidden) {
                [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromBannerEvent(kUnityAdsBannerEventVisibilityChanged) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) param1:[NSNumber numberWithInteger:kUnityAdsBannerVisibilityGone], nil];
            } else {
                [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromBannerEvent(kUnityAdsBannerEventVisibilityChanged) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) param1:[NSNumber numberWithInteger:kUnityAdsBannerVisibilityVisible], nil];
            }
        }
    }
}

-(void)setViewFrame:(NSString *)viewName x:(float)x y:(float)y width:(float)width height:(float)height {
    UIView *view = [self getViewByName:viewName];
    if (view) {
        if (view == self) {
            USRVLogWarning(@"Not setting viewFrame for banner, use `layoutWithStyle` instead.");
        } else {
            CGRect rect = CGRectMake(x, y, width, height);
            [view setFrame:rect];
        }
    }
}

-(UIView *)getViewByName:(NSString *)viewName {
    if ([viewName isEqualToString:@"bannerview"]) {
        return self;
    } else if ([viewName isEqualToString:@"bannerplayer"]) {
        return self.webPlayer;
    } else if ([viewName isEqualToString:@"webview"]) {
        return [[USRVWebViewApp getCurrentApp] webView];
    }
    return nil;
}

static dispatch_once_t onceToken;

+(UADSBannerView *)getOrCreateInstance {
    dispatch_once(&onceToken, ^{
        instance = [[UADSBannerView alloc] initWithFrame:CGRectZero];
    });
    return instance;
}

+(UADSBannerView *)getInstance {
    return instance;
}

+(void)destroyInstance {
    onceToken = 0L;
    instance = nil;
}

+(void)setWebPlayerSettings:(NSDictionary *)newSettings {
    webPlayerSettings = newSettings;
}

+(void)setWebPlayerEventSettings:(NSDictionary *)newSettings {
    webPlayerEventSettings = newSettings;
    if (instance) {
        [instance.webPlayer setEventSettings:webPlayerEventSettings];
    }
}


@end
