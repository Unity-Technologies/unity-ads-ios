#import <Foundation/Foundation.h>
#import "UnityAdsDelegateMock.h"

@implementation UnityAdsDelegateMock

// UnityAdsDelegate Methods
- (void)unityAdsReady: (NSString *)placementId {
}

- (void)unityAdsDidError: (UnityAdsError)error withMessage: (NSString *)message {
}

- (void)unityAdsDidStart: (NSString *)placementId {
}

- (void)unityAdsDidFinish: (NSString *)placementId
          withFinishState: (UnityAdsFinishState)state {
}

@end
