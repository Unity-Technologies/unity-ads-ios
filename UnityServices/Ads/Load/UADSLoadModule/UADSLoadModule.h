#import "UADSAbstractModule.h"
#import "UADSLoadModule.h"
#import "UADSLoadModuleDelegateWrapper.h"
#import "UADSLoadOptions.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSLoadModule: UADSAbstractModule
-(void)sendAdLoadedForPlacementID: (NSString*)placementID
                    andListenerID: (NSString*)listenerID;

-(void)sendAdFailedToLoadForPlacementID:(NSString*_Nonnull)placementID
                             listenerID:(NSString*_Nonnull)listenerID
                                message:(NSString*_Nonnull)message
                                  error:(UnityAdsLoadError)error;

-(void)loadForPlacementID: (NSString *)placementID
                  options: (UADSLoadOptions*)options
             loadDelegate: (nullable id<UnityAdsLoadDelegate>)loadDelegate;
    
@end

NS_ASSUME_NONNULL_END
