#import "USRVInitializationDelegate.h"
#import "UnityAdsLoadDelegate.h"
#import "USRVConfiguration.h"
#import "UADSLoadOptions.h"

@interface UADSLoadModule : NSObject <USRVInitializationDelegate>
+(instancetype _Nonnull )sharedInstance;

-(void)load:(NSString *_Nonnull)placementId options:(UADSLoadOptions*_Nonnull)options loadDelegate:(nullable id<UnityAdsLoadDelegate>)loadDelegate;

-(void)sendAdLoaded:(NSString*_Nonnull)placementId listenerId:(NSString*_Nonnull)listenerId;

-(void)sendAdFailedToLoad:(NSString*_Nonnull)placementId listenerId:(NSString*_Nonnull)listenerId;

+(void)loadCallback:(NSArray *)params;

+(void)setConfiguration:(USRVConfiguration *)config;

@end
