#import "UnityAdsShowDelegateMock.h"
#import "UADSTools.h"
@implementation UnityAdsShowDelegateMock
@synthesize expectation;
- (instancetype)init {
    SUPER_INIT
    self.startedPlacements = [NSArray new];
    self.failedPlacements = [NSArray new];
    self.clickedPlacements = [NSArray new];
    self.completedPlacements = [NSArray new];
    self.failedReasons = [NSArray new];
    return self;
}

- (void)unityAdsShowClick: (nonnull NSString *)placementId {
    _clickedPlacements = [_clickedPlacements arrayByAddingObject: placementId];
    [self.expectation fulfill];
}

- (void)unityAdsShowComplete: (nonnull NSString *)placementId
             withFinishState: (UnityAdsShowCompletionState)state {
    _completedPlacements = [_completedPlacements arrayByAddingObject: placementId];
    [self.expectation fulfill];
}

- (void)unityAdsShowFailed: (nonnull NSString *)placementId
                 withError: (UnityAdsShowError)error
               withMessage: (nonnull NSString *)message {
    _failedPlacements = [_failedPlacements arrayByAddingObject: placementId];
    _failedReasons = [_failedReasons arrayByAddingObject: @(error)];
    [self.expectation fulfill];
}

- (void)unityAdsShowStart: (nonnull NSString *)placementId {
    _startedPlacements = [_startedPlacements arrayByAddingObject: placementId];
    [self.expectation fulfill];
}

@end
