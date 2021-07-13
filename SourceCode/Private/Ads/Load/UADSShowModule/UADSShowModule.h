#import "UnityAdsShowDelegate.h"
#import "UADSShowOptions.h"
#import "USRVClientProperties.h"
#import "UnityAdsShowError.h"
#import "UADShowDelegateWrapper.h"
#import "UADSTools.h"
#import "UADSAbstractModule.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSShowModule : UADSAbstractModule
- (void)showAdForPlacementID: (NSString *)placementID
                 withOptions: (id<UADSDictionaryConvertible>)options
             andShowDelegate: (nullable id<UnityAdsShowDelegate>)showDelegate;

- (void)sendShowFailedEvent: (NSString *_Nonnull)placementID
                 listenerID: (NSString *_Nonnull)listenerID
                    message: (NSString *_Nonnull)message
                      error: (UnityAdsShowError)error;

- (void)sendShowStartEvent: (NSString *_Nonnull)placementID
                listenerID: (NSString *_Nonnull)listenerID;

- (void)sendShowClickEvent: (NSString *_Nonnull)placementID
                listenerID: (NSString *_Nonnull)listenerID;

- (void)sendShowCompleteEvent: (NSString *_Nonnull)placementID
                   listenerID: (NSString *_Nonnull)listenerId
                        state: (UnityAdsShowCompletionState)state;

- (void)sendShowConsentEvent: (NSString *)placementID
                  listenerID: (NSString *)listenerID;

@end
NS_ASSUME_NONNULL_END
