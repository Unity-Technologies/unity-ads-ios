#import "GMAAdLoaderStrategy.h"
#import "GMAInterstitialAdLoaderV7.h"
#import "GMAInterstitialAdLoaderV8.h"
#import "GMARewardedAdLoaderV7.h"
#import "GMARewardedAdLoaderV8.h"
#import "GMAVersionReaderStrategy.h"
#import "GMAError.h"
static NSString *const kGMAAdLoaderStrategyNotFoundError = @"ERROR: Cannot find loader of type: %li";

@interface GMAAdLoaderStrategy ()
@property (strong, nonatomic) GMALoaderBase *interstitialLoader;
@property (strong, nonatomic) GMALoaderBase *rewardedLoader;
@property (strong, nonatomic) GMAVersionReaderStrategy *versionReader;
@end

@implementation GMAAdLoaderStrategy
+ (instancetype)newWithRequestFactory: (id<GADRequestFactory>)requestFactory
                   andDelegateFactory: (nonnull id<GMADelegatesFactory>)delegatesFactory {
    GMAAdLoaderStrategy *obj = [GMAAdLoaderStrategy new];

    obj.interstitialLoader = [self createInterstitialLoaderWithRequestFactory: requestFactory
                                                           andDelegateFactory: delegatesFactory];
    obj.rewardedLoader = [self createRewardedLoaderWithRequestFactory: requestFactory
                                                   andDelegateFactory: delegatesFactory];
    obj.versionReader = [[GMAVersionReaderStrategy alloc] init];
    return obj;
}

- (NSString *)currentVersion {
    if (self.isSupported) {
        return _versionReader.sdkVersion;
    } else {
        return kGMAVersionReaderUnavailableVersionString;
    }
}

- (BOOL)isSupported {
    return [self interstitialLoaderIsSupported] && [self rewardedLoaderIsSupported];
}

- (BOOL)interstitialLoaderIsSupported {
    return [GMAInterstitialAdLoaderV8 isSupported] || [GMAInterstitialAdLoaderV7 isSupported];
}

- (BOOL)rewardedLoaderIsSupported {
    return [GMARewardedAdLoaderV8 isSupported] || [GMARewardedAdLoaderV7 isSupported];
}

+ (GMALoaderBase *)createInterstitialLoaderWithRequestFactory: (id<GADRequestFactory>)requestFactory
                                           andDelegateFactory: (nonnull id<GMADelegatesFactory>)delegatesFactory  {
    if ([GMAInterstitialAdLoaderV8 isSupported]) {
        return [GMAInterstitialAdLoaderV8 newWithRequestFactory: requestFactory
                                             andDelegateFactory: delegatesFactory];
    }

    if ([GMAInterstitialAdLoaderV7 isSupported]) {
        return [GMAInterstitialAdLoaderV7 newWithRequestFactory: requestFactory
                                             andDelegateFactory: delegatesFactory];
    }

    return nil;
}

+ (GMALoaderBase *)createRewardedLoaderWithRequestFactory: (id<GADRequestFactory>)requestFactory
                                       andDelegateFactory: (nonnull id<GMADelegatesFactory>)delegatesFactory {
    if ([GMARewardedAdLoaderV8 isSupported]) {
        return [GMARewardedAdLoaderV8 newWithRequestFactory: requestFactory
                                         andDelegateFactory: delegatesFactory];
    }

    if ([GMARewardedAdLoaderV7 isSupported]) {
        return [GMARewardedAdLoaderV7 newWithRequestFactory: requestFactory
                                         andDelegateFactory: delegatesFactory];
    }

    return nil;
}

- (id<GMAAdLoader, UADSAdPresenter>)strategyForAdType: (GADQueryInfoAdType)type {
    switch (type) {
        case GADQueryInfoAdTypeInterstitial:
            return _interstitialLoader;

            break;

        case GADQueryInfoAdTypeRewarded:
            return _rewardedLoader;

            break;
    }
    return nil;
}

- (void)loadAdUsingMetaData: (GMAAdMetaData *)meta
              andCompletion: (UADSLoadAdCompletion *)completion; {
    id<GMAAdLoader> loader = [self strategyForAdType: meta.type];

    if (!loader) {
        [completion error: [GMAError newNonSupportedLoader: meta]];
        return;
    }

    [loader loadAdUsingMetaData: meta
                  andCompletion: completion];
}

- (void)showAdUsingMetaData: (GMAAdMetaData *)meta
           inViewController: (UIViewController *)viewController
                      error: (id<UADSError>  _Nullable __autoreleasing *)error {
    id<UADSAdPresenter> presenter = [self strategyForAdType: meta.type];

    if (!presenter) {
        *error = [GMAError newNonSupportedPresenter: meta];
        return;
    }

    [presenter showAdUsingMetaData: meta
                  inViewController: viewController
                             error: error];
}

@end
