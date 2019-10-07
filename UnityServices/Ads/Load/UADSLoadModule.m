#import "USRVSdkProperties.h"
#import "UADSLoadModule.h"
#import "UADSLoadBridge.h"
#import "USRVInitializationNotificationCenter.h"

@interface UADSLoadModule ()

@property(nonatomic, strong) NSObject <UADSLoadBridgeProtocol> *loadBridge;
@property(nonatomic, strong) NSObject <USRVInitializationNotificationCenterProtocol> *initializationNotificationCenter;
@property(nonatomic, strong) NSMutableDictionary *loadEventBuffer;

@end

@implementation UADSLoadModule

+(instancetype)sharedInstance {
    static UADSLoadModule *sharedLoadEventManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UADSLoadBridge *loadBridge = [[UADSLoadBridge alloc] init];
        USRVInitializationNotificationCenter *initializationNotificationCenter = [USRVInitializationNotificationCenter sharedInstance];
        sharedLoadEventManager = [[UADSLoadModule alloc] initWithBridge:loadBridge initializationNotificationCenter:initializationNotificationCenter];
    });
    return sharedLoadEventManager;
}

-(instancetype)initWithBridge:(NSObject <UADSLoadBridgeProtocol> *)bridge initializationNotificationCenter:(NSObject <USRVInitializationNotificationCenterProtocol> *)initializeNotificationCenter {

    self = [super init];

    if (self) {
        _loadBridge = bridge;
        _initializationNotificationCenter = initializeNotificationCenter;
        _loadEventBuffer = [[NSMutableDictionary alloc] init];
        [self.initializationNotificationCenter addDelegate:self];
    }
    return self;
}

- (dispatch_queue_t)getSynchronize {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

-(void)load:(NSString *)placementId {
    if (placementId == nil) {
        USRVLogError(@"ERROR: Loaded placements cannot be nil");
        return;
    }
    __weak UADSLoadModule *weakSelf = self;
    dispatch_sync([self getSynchronize], ^{
        if (!weakSelf) {
            return;
        }
        NSNumber* loadCount = [weakSelf.loadEventBuffer objectForKey:placementId];

        if (loadCount != nil) {
            [weakSelf.loadEventBuffer setObject:[NSNumber numberWithInt:[loadCount integerValue] + 1.0] forKey:placementId];
        } else {
            [weakSelf.loadEventBuffer setObject:[NSNumber numberWithInt:1] forKey:placementId];
        }

        if ([USRVSdkProperties isInitialized]) {
            [weakSelf sendLoadEvents];
        }
    });
}

-(void)sendLoadEvents {
    NSDictionary *placements = [[NSDictionary alloc] initWithDictionary:self.loadEventBuffer];
    if ([placements allKeys].count > 0) {
        [self.loadBridge loadPlacements:placements];
    }
    [self.loadEventBuffer removeAllObjects];
}

-(void)sdkDidInitialize {
    __weak UADSLoadModule *weakSelf = self;
    dispatch_sync([self getSynchronize], ^{
        if (!weakSelf) {
            return;
        }
        [weakSelf sendLoadEvents];
    });
}

-(void)sdkInitializeFailed:(NSError *)error {

}

@end
