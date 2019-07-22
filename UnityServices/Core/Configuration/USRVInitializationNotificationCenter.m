#import "USRVInitializationNotificationCenter.h"

@interface USRVInitializationDelegateWrapper : NSObject

@property(nonatomic, weak) NSObject <USRVInitializationDelegate> *delegate;

@end

@implementation USRVInitializationDelegateWrapper

-(instancetype)initWithDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

@end


@interface USRVInitializationNotificationCenter ()

@property(nonatomic, strong) dispatch_queue_t synchronizer;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, USRVInitializationDelegateWrapper *> *sdkDelegates;

@end

@implementation USRVInitializationNotificationCenter

// Public

+(instancetype)sharedInstance {
    static USRVInitializationNotificationCenter *sharedInitializationDelegateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInitializationDelegateManager = [[USRVInitializationNotificationCenter alloc] init];
    });
    return sharedInitializationDelegateManager;
}

// USRVInitializationNotificationCenterProtocol Methods

-(void)addDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate {
    NSNumber *delegateKey = [NSNumber numberWithInteger:[delegate hash]];
    USRVInitializationDelegateWrapper *wrapper = [[USRVInitializationDelegateWrapper alloc] initWithDelegate:delegate];
    __weak USRVInitializationNotificationCenter *weakSelf = self;
    dispatch_async(self.synchronizer, ^{
        if (weakSelf) {
            [weakSelf.sdkDelegates setObject:wrapper forKey:delegateKey];
        }
    });
}

-(void)removeDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate {
    NSNumber *delegateKey = [NSNumber numberWithInteger:[delegate hash]];
    [self removeDelegateWithKey:delegateKey];
}

-(void)triggerSdkDidInitialize {
    __weak USRVInitializationNotificationCenter *weakSelf = self;
    dispatch_async(self.synchronizer, ^{
        if (weakSelf) {
            NSDictionary *delegates = [NSDictionary dictionaryWithDictionary:weakSelf.sdkDelegates];
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSNumber *key in delegates) {
                    USRVInitializationDelegateWrapper *delegateWrapper = [delegates objectForKey:key];
                    @try {
                        if (delegateWrapper.delegate) {
                            [delegateWrapper.delegate sdkDidInitialize];
                        } else {
                            // clean up empty wrapper
                            [weakSelf removeDelegateWithKey:key];
                        }
                    }
                    @catch (NSException *exception) {
                        USRVLogError(@"%@ : %@", exception.name, exception.reason);
                    }
                }
            });
        }
    });
}

-(void)triggerSdkInitializeDidFail:(NSString *)message code:(int)code {
    __weak USRVInitializationNotificationCenter *weakSelf = self;
    dispatch_async(self.synchronizer, ^{
        if (weakSelf) {
            NSDictionary *delegates = [NSDictionary dictionaryWithDictionary:weakSelf.sdkDelegates];
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSNumber *key in delegates) {
                    USRVInitializationDelegateWrapper *delegateWrapper = [delegates objectForKey:key];
                    @try {
                        if (delegateWrapper.delegate) {
                            NSError *error = [[NSError alloc] initWithDomain:@"USRVInitializationNotificationCenter" code:code userInfo:@{@"message": message}];
                            [delegateWrapper.delegate sdkInitializeFailed:error];
                        } else {
                            // clean up empty wrapper
                            [weakSelf removeDelegateWithKey:key];
                        }
                    }
                    @catch (NSException *exception) {
                        USRVLogError(@"%@ : %@", exception.name, exception.reason);
                    }
                }
            });
        }
    });
}

// Private

-(instancetype)init {
    self = [super init];
    if (self) {
        self.synchronizer = dispatch_queue_create("com.unity3d.ads.USRVInitializationDelegateManagerQueue", NULL);
        self.sdkDelegates = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)removeDelegateWithKey:(NSNumber *)delegateKey {
    __weak USRVInitializationNotificationCenter *weakSelf = self;
    dispatch_async(self.synchronizer, ^{
        if (weakSelf) {
            [weakSelf.sdkDelegates removeObjectForKey:delegateKey];
        }
    });
}

@end
