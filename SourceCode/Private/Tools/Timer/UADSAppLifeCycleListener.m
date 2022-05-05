#import "UADSAppLifeCycleNotificationCenter.h"
#import <UIKit/UIKit.h>

@interface UADSAppLifeCycleMediator ()
@property (nonatomic, strong) NSMutableDictionary *didBecomeActiveCallbacks;
@property (nonatomic, strong) NSMutableDictionary *didEnterBackgroundCallbacks;
@end

@implementation UADSAppLifeCycleMediator

- (instancetype)init {
    SUPER_INIT

        _didBecomeActiveCallbacks = [NSMutableDictionary dictionary];

    _didEnterBackgroundCallbacks = [NSMutableDictionary dictionary];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didEnterBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    return self;
}

- (void)dealloc {
    _didBecomeActiveCallbacks = nil;
    _didEnterBackgroundCallbacks = nil;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (NSString *)addEventsListenerWithDidBecomeActive: (UADSVoidClosure)didBecomeActive didEnterBackground: (UADSVoidClosure)didEnterBackground {
    NSString *identifier = [[NSUUID UUID] UUIDString];

    @synchronized (self) {
        self.didBecomeActiveCallbacks[identifier] = didBecomeActive;
        self.didEnterBackgroundCallbacks[identifier] = didEnterBackground;
    }
    return identifier;
}

- (void)removeListener: (NSString *)identifier {
    @synchronized (self) {
        self.didBecomeActiveCallbacks[identifier] = nil;
        self.didEnterBackgroundCallbacks[identifier] = nil;
    }
}

- (void)didEnterBackground {
    @synchronized (self) {
        for (UADSVoidClosure block in self.didEnterBackgroundCallbacks.allValues) {
            block();
        }
    }
}

- (void)didBecomeActive {
    @synchronized (self) {
        for (UADSVoidClosure block in self.didBecomeActiveCallbacks.allValues) {
            block();
        }
    }
}

@end
