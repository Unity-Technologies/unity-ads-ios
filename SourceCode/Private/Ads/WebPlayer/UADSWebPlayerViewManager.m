#import "UADSWebPlayerViewManager.h"


@interface UADSWebPlayerViewManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, UADSWebPlayerView *> *webPlayerViews;

@end

@implementation UADSWebPlayerViewManager

// Public

+ (instancetype)sharedInstance {
    static UADSWebPlayerViewManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[UADSWebPlayerViewManager alloc] init];
    });
    return sharedInstance;
}

- (void)addWebPlayerView: (UADSWebPlayerView *)webPlayerView viewId: (NSString *)viewId {
    @synchronized (self) {
        [self.webPlayerViews setObject: webPlayerView
                                forKey: viewId];
    }
}

- (void)removeWebPlayerViewWithViewId: (NSString *)viewId {
    @synchronized (self) {
        [self.webPlayerViews removeObjectForKey: viewId];
    }
}

- (UADSWebPlayerView *_Nullable)getWebPlayerViewWithViewId: (NSString *)viewId {
    @synchronized (self) {
        return [self.webPlayerViews objectForKey: viewId];
    }
}

// Private

- (instancetype)init {
    self = [super init];

    if (self) {
        self.webPlayerViews = [[NSMutableDictionary alloc] init];
    }

    return self;
}

@end
