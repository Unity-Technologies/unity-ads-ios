#import "USRVSdkProperties.h"
#import "UADSLoadModule.h"
#import "USRVInitializationNotificationCenter.h"
#import "UADSProperties.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewApp.h"
#import "USRVSDKMetrics.h"
#import "USRVDevice.h"

static volatile NSCondition* lock = nil;
static volatile BOOL status = NO;
static USRVConfiguration *configuration = nil;

@interface LoadEventState : NSObject {
}
@property(nonatomic, readwrite) NSString* placementId;
@property(nonatomic, readwrite) NSString* listenerId;
@property(nonatomic, readwrite) NSNumber* time;
@property(nonatomic, readwrite) UADSLoadOptions* options;
@property(nonatomic, strong) id<UnityAdsLoadDelegate> delegate;
@end

@implementation LoadEventState

-(id)init {
   self = [super init];
   return self;
}

@end

@interface UADSLoadModule ()

@property(nonatomic, strong) NSObject <USRVInitializationNotificationCenterProtocol> *initializationNotificationCenter;
@property(nonatomic, strong) NSMutableDictionary *loadEventState;
@property(nonatomic, strong) NSMutableArray *loadEventBuffer;
@property(nonatomic, strong) dispatch_queue_t loadQueue;

@end

@implementation UADSLoadModule

+(instancetype)sharedInstance {
    static UADSLoadModule *sharedLoadEventManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        USRVInitializationNotificationCenter *initializationNotificationCenter = [USRVInitializationNotificationCenter sharedInstance];
        sharedLoadEventManager = [[UADSLoadModule alloc] initWithNotificationCenter:initializationNotificationCenter];
    });
    return sharedLoadEventManager;
}

-(instancetype)initWithNotificationCenter:(NSObject <USRVInitializationNotificationCenterProtocol> *)initializeNotificationCenter {

    self = [super init];

    if (self) {
        _loadQueue = dispatch_queue_create("unity-ads-load-api-queue", NULL);
        _initializationNotificationCenter = initializeNotificationCenter;
        _loadEventState = [[NSMutableDictionary alloc] init];
        _loadEventBuffer = [[NSMutableArray alloc] init];
        if (configuration == nil) {
            configuration = [[USRVConfiguration alloc] init];
            USRVLogError(@"Configuration is null, apply default configuration");
        }
        [self.initializationNotificationCenter addDelegate:self];
    }
    return self;
}

-(void) load:(NSString *)placementId
     options:(UADSLoadOptions*)options
loadDelegate:(nullable id<UnityAdsLoadDelegate>)loadDelegate {
    if (placementId == nil || [placementId isEqual: @""]) {
        [loadDelegate unityAdsAdFailedToLoad:placementId];
        return;
    }
    
    LoadEventState* loadEventState = [self createLoadEventState:placementId
                                                        options:options
                                                       listener:loadDelegate];
    
    if ([USRVSdkProperties isInitialized]) {
        dispatch_async(_loadQueue, ^{
            [self runLoadRequest:loadEventState];
        });
    } else {
        @synchronized (_loadEventBuffer) {
            [_loadEventBuffer addObject:loadEventState];
        }
    }
}

-(LoadEventState*)createLoadEventState:(NSString*)placementId
                               options:(UADSLoadOptions*)options
                              listener:(id<UnityAdsLoadDelegate>)listener {
    
    NSString* listenerId = [[NSUUID UUID] UUIDString];
    
    LoadEventState* state = [[LoadEventState alloc] init];
    
    state.delegate = listener;
    state.placementId = placementId;
    state.listenerId = listenerId;
    state.options = options;
    state.time = [USRVDevice getElapsedRealtime];
    
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([configuration noFillTimeout] * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
       [self sendAdFailedToLoad:placementId listenerId:listenerId];
    });
    
    @synchronized (_loadEventState) {
        [_loadEventState setObject:state forKey:listenerId];
    }
    
    return state;
}

-(void)runLoadRequest:(LoadEventState*)loadEventState {
    if (![UADSLoadModule load:loadEventState]) {
        [self sendAdFailedToLoad:loadEventState.placementId listenerId:loadEventState.listenerId];
    }
}

-(void)sendAdLoaded:(NSString*)placementId listenerId:(NSString*)listenerId {
    LoadEventState* loadEventState = nil;
    @synchronized (_loadEventState) {
        loadEventState = [_loadEventState objectForKey:listenerId];
        [_loadEventState removeObjectForKey:listenerId];
    }
    
    if (loadEventState == nil) {
        return;
    }
    
    if (loadEventState.delegate == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadEventState.delegate unityAdsAdLoaded:placementId];
    });
}

-(void)sendAdFailedToLoad:(NSString*)placementId listenerId:(NSString*)listenerId {
    LoadEventState* loadEventState = nil;
    @synchronized (_loadEventState) {
        loadEventState = [_loadEventState objectForKey:listenerId];
        [_loadEventState removeObjectForKey:listenerId];
    }
    
    if (loadEventState == nil) {
        return;
    }
    
    if (loadEventState.delegate == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadEventState.delegate unityAdsAdFailedToLoad:placementId];
    });
}

-(void)sdkDidInitialize {
    NSArray* loadEventBuffer;
    @synchronized (_loadEventBuffer) {
        loadEventBuffer = [_loadEventBuffer copy];
        [_loadEventBuffer removeAllObjects];
    }
    
    dispatch_async(_loadQueue, ^{
        [loadEventBuffer enumerateObjectsUsingBlock:^(LoadEventState* loadEventState, NSUInteger idx, BOOL* stop) {
            [self runLoadRequest:loadEventState];
        }];
    });
}

-(void)sdkInitializeFailed:(NSError *)error {
    NSArray* loadEventBuffer;
    @synchronized (_loadEventBuffer) {
        loadEventBuffer = [_loadEventBuffer copy];
        [_loadEventBuffer removeAllObjects];
    }
    
    [loadEventBuffer enumerateObjectsUsingBlock:^(LoadEventState* loadEventState, NSUInteger idx, BOOL* stop) {
        [self sendAdFailedToLoad:loadEventState.placementId listenerId:loadEventState.listenerId];
    }];
}

+(BOOL)load:(LoadEventState*)loadEventState {
    NSString *receiverClass = NSStringFromClass(self.class);
    NSString *receiverSelector = @"loadCallback:";
    
    NSDictionary* dictionary = @{
        @"placementId" : loadEventState.placementId,
        @"listenerId" : loadEventState.listenerId,
        @"time": loadEventState.time,
        @"options": loadEventState.options.dictionary
    };

    lock = [[NSCondition alloc] init];

    [[USRVWebViewApp getCurrentApp] invokeMethod:@"load" className:@"webview" receiverClass:receiverClass callback:receiverSelector params:@[dictionary]];
    
    status = NO;
    
    [lock lock];
    bool signaled = [lock waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:[configuration loadTimeout]/1000]];
    [lock unlock];
    lock = nil;
    
    if (!signaled) {
        [[USRVSDKMetrics getInstance] sendEvent:@"native_load_callback_failed"];
    }
    
    return signaled && status;
}

+(void)loadCallback: (NSArray *)params {
    if (lock) {
        [lock lock];
        status = [[params objectAtIndex:0] isEqualToString:@"OK"];
        [lock signal];
        [lock unlock];
    }
}

+ (void)setConfiguration:(USRVConfiguration *)config {
    configuration = config;
}

@end
