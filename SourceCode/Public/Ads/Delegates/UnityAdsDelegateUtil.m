#import "UnityAdsDelegateUtil.h"
#import "UADSProperties.h"
#import "UnityAdsExtendedDelegate.h"

@implementation UnityAdsDelegateUtil

// Public

+ (void)unityAdsReady: (NSString *)placementId {
    [UnityAdsDelegateUtil unityAdsRunSelector: @selector(unityAdsReady:)
                                        block: ^(id <UnityAdsDelegate> delegate) {
                                            [delegate unityAdsReady: placementId];
                                        }];
}

+ (void)unityAdsDidError: (UnityAdsError)error withMessage: (NSString *)message {
    [UnityAdsDelegateUtil unityAdsRunSelector: @selector(unityAdsDidError:withMessage:)
                                        block: ^(id <UnityAdsDelegate> delegate) {
                                            [delegate unityAdsDidError: error
                                                           withMessage: message];
                                        }];
}

+ (void)unityAdsDidStart: (NSString *)placementId {
    [UnityAdsDelegateUtil unityAdsRunSelector: @selector(unityAdsDidStart:)
                                        block: ^(id <UnityAdsDelegate> delegate) {
                                            [delegate unityAdsDidStart: placementId];
                                        }];
}

+ (void)unityAdsDidFinish: (NSString *)placementId
          withFinishState: (UnityAdsFinishState)state {
    [UnityAdsDelegateUtil unityAdsRunSelector: @selector(unityAdsDidFinish:withFinishState:)
                                        block: ^(id <UnityAdsDelegate> delegate) {
                                            [delegate unityAdsDidFinish: placementId
                                                        withFinishState: state];
                                        }];
}

+ (void)unityAdsDoClick: (NSString *)placementId {
    [UnityAdsDelegateUtil unityAdsRunSelector: @selector(unityAdsDidClick:)
                                        block: ^(id <UnityAdsDelegate> delegate) {
                                            if (delegate && [delegate conformsToProtocol: @protocol(UnityAdsExtendedDelegate)]) {
                                                if ([(id<UnityAdsExtendedDelegate>) delegate
                  respondsToSelector: @selector(unityAdsDidClick:)]) {
                                                    [(id<UnityAdsExtendedDelegate>) delegate
                  unityAdsDidClick: placementId];
                                                }
                                            }
                                        }];
}

+ (void)unityAdsPlacementStateChange: (NSString *)placementId oldState: (UnityAdsPlacementState)oldState newState: (UnityAdsPlacementState)newState {
    [UnityAdsDelegateUtil unityAdsRunSelector: @selector(unityAdsPlacementStateChanged:oldState:newState:)
                                        block: ^(id <UnityAdsDelegate> delegate) {
                                            if (delegate && [delegate conformsToProtocol: @protocol(UnityAdsExtendedDelegate)]) {
                                                if ([(id<UnityAdsExtendedDelegate>) delegate
                  respondsToSelector: @selector(unityAdsPlacementStateChanged:oldState:newState:)]) {
                                                    [(id<UnityAdsExtendedDelegate>) delegate
                  unityAdsPlacementStateChanged: placementId
                                       oldState: oldState
                                       newState: newState];
                                                }
                                            }
                                        }];
}

// Private

+ (void)unityAdsRunSelector: (SEL)delegateMethod block: (void (^)(id <UnityAdsDelegate>))block {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSOrderedSet *delegates = [UADSProperties getDelegates];

        for (id <UnityAdsDelegate> delegate in delegates) {
            if (delegate) {
                if ([delegate respondsToSelector: delegateMethod]) {
                    block(delegate);
                }
            }
        }
    });
}

@end
