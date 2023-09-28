#import "UADSApiGMAScar.h"
#import "USRVWebViewApp.h"
#import "USRVClientProperties.h"
#import "UADSGMAScar.h"
#import "NSError+UADSError.h"
#import "GMAAdLoaderStrategy.h"
#import "GADBaseAd.h"
#import "GMAWebViewEvent.h"
#import "UADSTools.h"
#import "UADSWebViewErrorHandler.h"
#import "GMAError.h"
@implementation UADSApiGMAScar

+ (UADSGMAScar *)facade {
    return UADSGMAScar.sharedInstance;
}

+ (id<UADSWebViewEventSender>)eventSender {
    return [UADSWebViewEventSenderBase new];
}

+ (id<UADSErrorHandler>)errorHandler {
    return self.facade.errorHandler;
}

+ (void)WebViewExposed_getVersion: (USRVWebViewCallback *)callback {
    [self sendAvailabilityMetrics];

    [callback invoke: self.facade.sdkVersion, nil];
}

+ (void)WebViewExposed_isAvailable: (USRVWebViewCallback *)callback {
    BOOL present = self.facade.isAvailable;

    [callback invoke: [NSNumber numberWithBool: present], nil];
}

+(void)WebViewExposed_getSCARSignal: (NSString *)placementId
                           adFormat: (NSString *)adFormat
                           callback: (USRVWebViewCallback *)callback {
    id success = ^(NSString *_Nullable signals) {
        GMAWebViewEvent *event = [GMAWebViewEvent newSignalsEvent: signals];
        [self sendEvent: event];
    };

    id error = ^(id<UADSError> _Nonnull error) {
        [self.errorHandler catchError: error];
    };

    UADSGMAEncodedSignalsCompletion *completion =  [UADSGMAEncodedSignalsCompletion newWithSuccess: success andError: error];
    UADSScarSignalParameters *params = [[UADSScarSignalParameters alloc] initWithPlacementId:placementId adFormat: [self getInfoAdTypeFrom:adFormat]];
    [self.facade getSCARSignals: @[ params ]
                     completion: completion];
}

+ (void)WebViewExposed_load: (NSString *)placementId
                 responseID: (NSString *)responseID
                       skip: (NSNumber *)skip
                   adUnitID: (NSString *)adUnitID
                   adString: (NSString *)adString
                videoLength: (NSNumber *)videoLength
                   callback: (USRVWebViewCallback *)callback {
    GADQueryInfoAdType type = [self getTypeFromNumber: skip];

    GMAAdMetaData *data = [GMAAdMetaData new];

    data.type = type;
    data.placementID = placementId ? : kUADS_EMPTY_STRING;
    data.adString = adString ? : kUADS_EMPTY_STRING;
    data.adUnitID = adUnitID ? : kUADS_EMPTY_STRING;
    data.videoLength = videoLength ? : @0;
    data.queryID = responseID ? : kUADS_EMPTY_STRING;


    id successHandler = ^(GADBaseAd *_Nullable ad) {
        GMAWebViewEvent *event = [GMAWebViewEvent newAdLoadedWithMeta: data
                                                          andLoadedAd: ad];
        [self sendEvent: event];
    };

    id errorHandler = ^(id<UADSError> _Nonnull error) {
        [self.facade.errorHandler catchError: error];
    };

    UADSLoadAdCompletion *completion = [UADSLoadAdCompletion newWithSuccess: successHandler
                                                                   andError: errorHandler];

    [self.facade loadAdUsingMetaData: data
                       andCompletion: completion];

    [callback invoke: nil];
}

+ (GADQueryInfoAdType)getTypeFromNumber: (NSNumber *)skip {
    if (skip.boolValue) {
        return GADQueryInfoAdTypeInterstitial;
    } else {
        return GADQueryInfoAdTypeRewarded;
    }
}

+ (void)WebViewExposed_show: (NSString *)placementId
                    queryID: (NSString *)queryID
                       skip: (NSNumber *)skip
                   callback: (USRVWebViewCallback *)callback {
    UIViewController *currentVC = [USRVClientProperties getCurrentViewController];
    GMAAdMetaData *data = [GMAAdMetaData new];

    data.type = [self getTypeFromNumber: skip];
    data.placementID = placementId ? : kUADS_EMPTY_STRING;
    data.queryID = queryID ? : kUADS_EMPTY_STRING;
    [self.facade showAdUsingMetaData: data
                    inViewController: currentVC];

    [callback invoke: nil];
}

+ (void)sendEvent: (id<UADSWebViewEvent>)event {
    [self.eventSender sendEvent: event];
}

+ (void)sendAvailabilityMetrics {
    if (self.facade.isGADExists) {
        [self sendEvent: [GMAWebViewEvent newScarPresent]];

        if (!self.facade.isGADSupported) {
            [self sendEvent: [GMAWebViewEvent newScarUnsupported]];
        }
    } else {
        [self sendEvent: [GMAWebViewEvent newScarNotPresent]];
    }
}

+ (GADQueryInfoAdType)getInfoAdTypeFrom: (NSString *)adFormat {
    if ([adFormat isEqualToString: @"interstitial"]) {
        return GADQueryInfoAdTypeInterstitial;
    }
    if ([adFormat isEqualToString: @"rewarded"]) {
        return GADQueryInfoAdTypeRewarded;
    }
    return GADQueryInfoAdTypeBanner;
}

@end
