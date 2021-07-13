#import "UnityAdsLoadDelegateMock.h"
#import "UADSTools.h"
@implementation UnityAdsLoadDelegateMock
@synthesize expectation;
- (instancetype)init {
    SUPER_INIT
    self.succeedPlacements = [NSArray new];
    self.failedPlacements = [NSArray new];
    self.errorCodes = [NSArray new];
    self.errorMessages = [NSArray new];
    return self;
}

- (void)unityAdsAdFailedToLoad: (NSString *)placementId
                     withError: (UnityAdsLoadError)error
                   withMessage: (NSString *)message {
    _failedPlacements = [_failedPlacements arrayByAddingObject: placementId];
    _errorCodes = [_errorCodes arrayByAddingObject: [NSNumber numberWithInteger: error]];
    _errorMessages = [_errorMessages arrayByAddingObject: message];
    [self fulfill];
}

- (void)unityAdsAdLoaded: (nonnull NSString *)placementId {
    _succeedPlacements = [_succeedPlacements arrayByAddingObject: placementId];
    [self fulfill];
}

- (void)fulfill {
    if ((_failedPlacements.count + _succeedPlacements.count) == 1) {
        [self.expectation fulfill];
    }
}

@end
