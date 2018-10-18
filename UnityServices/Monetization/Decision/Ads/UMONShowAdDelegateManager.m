#import "UMONShowAdDelegateManager.h"

@interface UMONShowAdDelegateManager ()
@property (strong, nonatomic) NSMutableDictionary<NSString*, id<UMONShowAdDelegate>>* delegateMap;
@end

@implementation UMONShowAdDelegateManager
+(UMONShowAdDelegateManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static UMONShowAdDelegateManager* instance;
    dispatch_once(&onceToken, ^{
        instance = [[UMONShowAdDelegateManager alloc] init];
    });

    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        self.delegateMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)setDelegate:(id <UMONShowAdDelegate>)delegate forPlacementId:(NSString *)placementId {
    self.delegateMap[placementId] = delegate;
}

-(void)sendAdFinished:(NSString *)placementId withFinishState:(UnityAdsFinishState)finishState {
    id<UMONShowAdDelegate> delegate = self.delegateMap[placementId];
    if (delegate != nil && [delegate respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
        [delegate unityAdsDidFinish:placementId withFinishState:finishState];
    }
    [self.delegateMap removeObjectForKey:placementId];
}

-(void)sendAdStarted:(NSString *)placementId {
    id<UMONShowAdDelegate> delegate = self.delegateMap[placementId];
    if (delegate != nil && [delegate respondsToSelector:@selector(unityAdsDidStart:)]) {
        [delegate unityAdsDidStart:placementId];
    }
}

@end
