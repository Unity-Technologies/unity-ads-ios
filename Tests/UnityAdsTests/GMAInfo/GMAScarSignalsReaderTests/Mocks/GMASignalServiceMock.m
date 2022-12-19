#import "GMASignalServiceMock.h"
#import "UADSTools.h"
typedef NSMutableDictionary<NSString *, UADSGMASCARCompletion *> CompletionMap;

@interface GMASignalServiceMock ()
@property (nonatomic, assign) NSUInteger rewardSignalsCalls;
@property (nonatomic, assign) NSUInteger interstitialCalls;
@property (nonatomic, strong) CompletionMap *interstitialCompletions;
@property (nonatomic, strong) CompletionMap *rewardCompletions;
@end

@implementation GMASignalServiceMock
- (instancetype)init {
    SUPER_INIT
    self.interstitialCompletions = [[CompletionMap alloc] init];
    self.rewardCompletions = [[CompletionMap alloc] init];
    return self;
}

- (void)getSignalOfAdType: (GADQueryInfoAdType)adType
           forPlacementId: (nonnull NSString *)placementId
               completion: (nonnull UADSGMASCARCompletion *)completionHandler {
    CompletionMap *map;

    switch (adType) {
        case GADQueryInfoAdTypeInterstitial:
            _interstitialCalls += 1;
            map = _interstitialCompletions;
            break;

        case GADQueryInfoAdTypeRewarded:
            _rewardSignalsCalls += 1;
            map = _rewardCompletions;
            break;
    }
    [map setValue: completionHandler
           forKey: placementId];
}

- (void)callSuccessForType: (GADQueryInfoAdType)adType
            forPlacementId: (nonnull NSString *)placementId
                    signal: (NSString *)signal {
    [[[self getMapOfType: adType] valueForKey: placementId] success: signal];
}

- (void)callErrorForType: (GADQueryInfoAdType)adType
          forPlacementId: (nonnull NSString *)placementId
                   error: (id<UADSError>)error {
    [[[self getMapOfType: adType] valueForKey: placementId] error: error];
}

- (CompletionMap *)getMapOfType: (GADQueryInfoAdType)type  {
    switch (type) {
        case GADQueryInfoAdTypeInterstitial:
            return _interstitialCompletions;

        case  GADQueryInfoAdTypeRewarded:
            return _rewardCompletions;
    }
}

- (NSUInteger)numberOfCallsForType: (GADQueryInfoAdType)type {
    switch (type) {
        case GADQueryInfoAdTypeRewarded:
            return _rewardSignalsCalls;

        case GADQueryInfoAdTypeInterstitial:
            return _interstitialCalls;
    }
}

- (nullable GADRequestBridge *)getAdRequestFor: (nonnull NSString *)placementId
                                 usingAdString: (nonnull NSString *)adString
                                         error: (id<UADSError>  _Nullable __autoreleasing *_Nullable)error {
    return nil;
}

@end
