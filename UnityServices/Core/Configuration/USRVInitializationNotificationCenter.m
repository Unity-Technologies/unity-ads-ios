#import "USRVInitializationNotificationCenter.h"

@interface USRVInitializationDelegateWrapper : NSObject

@property(nonatomic, weak) NSObject <USRVInitializationDelegate> *delegate;

@end

@implementation USRVInitializationDelegateWrapper

- (instancetype)initWithDelegate:(NSObject <USRVInitializationDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

@end


@interface USRVInitializationNotificationCenter ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, USRVInitializationDelegateWrapper *> *sdkDelegates;

@end

@implementation USRVInitializationNotificationCenter

// Public

+ (instancetype)sharedInstance {
    static USRVInitializationNotificationCenter *sharedInitializationDelegateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInitializationDelegateManager = [[USRVInitializationNotificationCenter alloc] init];
    });
    return sharedInitializationDelegateManager;
}

// USRVInitializationNotificationCenterProtocol Methods

- (void)addDelegate:(NSObject <USRVInitializationDelegate> *)delegate {
    NSNumber *delegateKey = [NSNumber numberWithInteger:[delegate hash]];
    USRVInitializationDelegateWrapper *wrapper = [[USRVInitializationDelegateWrapper alloc] initWithDelegate:delegate];
    @synchronized (self) {
        [self.sdkDelegates setObject:wrapper forKey:delegateKey];
    }
}

- (void)removeDelegate:(NSObject <USRVInitializationDelegate> *)delegate {
    NSNumber *delegateKey = [NSNumber numberWithInteger:[delegate hash]];
    [self removeDelegateWithKey:delegateKey];
}

- (void)triggerSdkDidInitialize {
    @synchronized (self) {
        NSDictionary *delegates = [NSDictionary dictionaryWithDictionary:self.sdkDelegates];
        __weak USRVInitializationNotificationCenter *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSNumber *key in delegates) {
                USRVInitializationDelegateWrapper *delegateWrapper = [delegates objectForKey:key];
                @try {
                    if (delegateWrapper.delegate) {
                        [delegateWrapper.delegate sdkDidInitialize];
                    } else {
                        // clean up empty wrapper
                        if (weakSelf) {
                            [weakSelf removeDelegateWithKey:key];
                        }
                    }
                }
                @catch (NSException *exception) {
                    USRVLogError(@"%@ : %@", exception.name, exception.reason);
                }
            }
        });
    }
}

- (void)triggerSdkInitializeDidFail:(NSString *)message code:(int)code {
    @synchronized (self) {
        NSDictionary *delegates = [NSDictionary dictionaryWithDictionary:self.sdkDelegates];
        __weak USRVInitializationNotificationCenter *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSNumber *key in delegates) {
                USRVInitializationDelegateWrapper *delegateWrapper = [delegates objectForKey:key];
                @try {
                    if (delegateWrapper.delegate) {
                        NSError *error = [[NSError alloc] initWithDomain:@"USRVInitializationNotificationCenter" code:code userInfo:@{@"message": message}];
                        [delegateWrapper.delegate sdkInitializeFailed:error];
                    } else {
                        // clean up empty wrapper
                        if (weakSelf) {
                            [weakSelf removeDelegateWithKey:key];
                        }
                    }
                }
                @catch (NSException *exception) {
                    USRVLogError(@"%@ : %@", exception.name, exception.reason);
                }
            }
        });
    }
}

// Private

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sdkDelegates = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)removeDelegateWithKey:(NSNumber *)delegateKey {
    @synchronized (self) {
        [self.sdkDelegates removeObjectForKey:delegateKey];
    }
}

@end
