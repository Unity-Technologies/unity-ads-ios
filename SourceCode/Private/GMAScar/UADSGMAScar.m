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
#import "GMAQueryInfoRequestFactory.h"
#import "GMAQueryInfoRequestFactoryV85.h"
#import "GMABaseQuerySignalReaderV85.h"
#import "GMAVersionReaderStrategy.h"

static NSString *const kUADSGMAScarNotPresentError = @"ERROR: Required GMA SDK classes are not present. Cannot get SCAR signals.";
static NSString* kLastQueryInfoRequestId = @"0";

@interface UADSGMAScar ()

@property (strong, nonatomic) id<GMAEncodedSCARSignalsReader> signalService;
@property (strong, nonatomic) id<GMAAdLoader, UADSAdPresenter, GMAVersionChecker> loaderStrategy;
@end

@implementation UADSGMAScar

+ (instancetype)defaultInfo {
    id<UADSWebViewEventSender>eventSender = [UADSWebViewEventSenderBase new];
    return [[self alloc] initWithEventSender: eventSender];
}

- (instancetype)initWithEventSender: (id<UADSWebViewEventSender>)eventSender {
    SUPER_INIT
    
    id<GMAQueryInfoReader> queryInfoReader = [self queryInfoReader];
    id<GMASignalService> signalReader = [self signalReaderWithQueryInfo:queryInfoReader];
    GMABaseSCARSignalsReader *signalsService = [GMABaseSCARSignalsReader newWithSignalService:signalReader];
    GMASCARSignalsReaderDecorator *encoder = [GMASCARSignalsReaderDecorator newWithSignalService: signalsService];
    
    id<UADSErrorHandler> errorHandler = [UADSWebViewErrorHandler newWithEventSender: eventSender];
    GMADelegatesBaseFactory *delegatesFactory = [GMADelegatesBaseFactory newWithEventSender: eventSender
                                                                               errorHandler: errorHandler];
    GMAAdLoaderStrategy *strategy = [GMAAdLoaderStrategy newWithRequestFactory: signalsService
                                                            andDelegateFactory: delegatesFactory];
    
    self.errorHandler = errorHandler;
    self.signalService = encoder;
    self.loaderStrategy = strategy;
    
    return self;
}

- (id<GMAQueryInfoReader>)queryInfoReader {
    id<GMAQueryInfoRequestFactory> requestFactory;
    if ([GMABaseQuerySignalReaderV85 isSupported]) {
        requestFactory = [GMAQueryInfoRequestFactoryV85 new];
    } else {
        requestFactory = [GMAQueryInfoRequestFactoryBase new];
    }
    return [GMABaseQueryInfoReader newWithRequestFactory:requestFactory];
}

- (id<GMASignalService>)signalReaderWithQueryInfo:(id<GMAQueryInfoReader>)queryInfoReader {
    id<GMASignalService> signalReader;
    if ([GMABaseQuerySignalReaderV85 isSupported]) {
        signalReader = [GMABaseQuerySignalReaderV85 newWithInfoReader:queryInfoReader];
    } else {
        signalReader = [GMABaseQuerySignalReader newWithInfoReader:queryInfoReader];
    }
    return signalReader;
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
