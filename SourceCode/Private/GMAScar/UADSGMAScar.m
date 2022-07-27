#import "UADSGMAScar.h"
#import "USRVClientProperties.h"
#import "USRVWebViewApp.h"
#import "GMAScarSignalsReader.h"
#import "UADSDefaultError.h"
#import "GMAScarSignalsReaderDecorator.h"
#import "GADMobileAdsBridge.h"
#import "UADSWebViewEventSender.h"
#import "GMAWebViewEvent.h"
#import "GMAError.h"

static NSString *const kUADSGMAScarNotPresentError = @"ERROR: Required GMA SDK classes are not present. Cannot get SCAR signals.";

@interface UADSGMAScar ()

@property (strong, nonatomic) id<GMAEncodedSCARSignalsReader> signalService;
@property (strong, nonatomic) id<GMAAdLoader, UADSAdPresenter, GMAVersionChecker> loaderStrategy;
@end

@implementation UADSGMAScar

+ (instancetype)defaultInfo {
    GMABaseSCARSignalsReader *signalsService = GMABaseSCARSignalsReader.defaultService;
    GMASCARSignalsReaderDecorator *encoder = [GMASCARSignalsReaderDecorator newWithSignalService: signalsService];

    id<UADSWebViewEventSender>eventSender = [UADSWebViewEventSenderBase new];
    id<UADSErrorHandler>errorHandler = [UADSWebViewErrorHandler newWithEventSender: eventSender];
    GMADelegatesBaseFactory *delegatesFactory = [GMADelegatesBaseFactory newWithEventSender: eventSender
                                                                               errorHandler: errorHandler];
    GMAAdLoaderStrategy *strategy = [GMAAdLoaderStrategy newWithRequestFactory: signalsService
                                                            andDelegateFactory: delegatesFactory];

    return [[self alloc] initWithSignalService: encoder
                             andLoaderStrategy: strategy
                               andErrorHandler: errorHandler];
}

- (instancetype)initWithSignalService: (id<GMAEncodedSCARSignalsReader>)signalService
                    andLoaderStrategy: (id<GMAAdLoader, UADSAdPresenter, GMAVersionChecker>)loaderStrategy
                      andErrorHandler: (id<UADSErrorHandler>)errorHandler {
    SUPER_INIT
    self.signalService = signalService;
    self.loaderStrategy = loaderStrategy;
    self.errorHandler = errorHandler;
    return self;
}

- (NSString *)sdkVersion {
    return [_loaderStrategy currentVersion];
}

- (BOOL)isAvailable {
    return self.isGADSupported && self.isGADExists;
}

- (BOOL)isGADSupported {
    return [_loaderStrategy isSupported];
}

- (BOOL)isGADExists {
    return [GADMobileAdsBridge exists];
}

- (void)getSCARSignalsUsingInterstitialList: (NSArray *)interstitialList
                            andRewardedList: (NSArray *)rewardedList
                                 completion: (UADSGMAEncodedSignalsCompletion *)completion {
    if (!self.isAvailable) {
        [completion error: GMAError.newInternalSignalsError];
        return;
    }

    [_signalService getSCARSignalsUsingInterstitialList: interstitialList
                                        andRewardedList: rewardedList
                                             completion: completion];
}

- (void)loadAdUsingMetaData: (GMAAdMetaData *)meta
              andCompletion: (UADSLoadAdCompletion *)completion {
    [_loaderStrategy loadAdUsingMetaData: meta
                           andCompletion: completion];
}

- (void)showAdUsingMetaData: (GMAAdMetaData *)meta
           inViewController: (UIViewController *)viewController {
    id<UADSError> error;

    [_loaderStrategy showAdUsingMetaData: meta
                        inViewController: viewController
                                   error: &error];

    if (error) {
        [_errorHandler catchError:  error];
    }
}

+ (UADSGMAScar *)sharedInstance {
    static UADSGMAScar *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [self defaultInfo];
    });
    return instance;
}

@end
