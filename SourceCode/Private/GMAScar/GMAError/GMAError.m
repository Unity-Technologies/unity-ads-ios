#import "GMAError.h"
#import "UADSTools.h"
#import "NSError+UADSError.h"

@interface GMAError ()
@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) GMAAdMetaData *meta;
@property (nonatomic, copy) NSString *errorCategory;
@property (nonatomic, strong) NSArray *errorParams;
@end


@implementation GMAError
+ (instancetype)newFromError: (id<UADSError>)error
                 andMetaData: (GMAAdMetaData *)meta
                 andCategory: (NSString *)category {
    return [self newInternalWithMessage: error.errorString
                            andMetaData: meta
                            andCategory: category
                               andError: error];
}

+ (instancetype)newInternalWithMessage: (NSString *)message
                           andMetaData: (GMAAdMetaData *)meta
                           andCategory: (NSString *)category {
    return [self newInternalWithMessage: message
                            andMetaData: meta
                            andCategory: category
                               andError: nil];
}

+ (instancetype)newInternalWithMessage: (NSString *)message
                           andMetaData: (GMAAdMetaData *)meta
                           andCategory: (NSString *)category
                              andError: (__nullable id<UADSError>)error {
    GMAError *gmaError = [GMAError new];

    gmaError.code = @(-1);
    gmaError.meta = meta;
    gmaError.message = message;
    gmaError.errorCategory = category;

    if (error) {
        gmaError.code = error.errorCode;
        gmaError.errorParams = [self errorParamsFromError: error];
    } else {
        gmaError.errorParams = @[gmaError.message];
    }

    return gmaError;
}

//MARK: - UADSError
- (nonnull NSString *)errorDomain {
    return @"GMA";
}

- (nonnull NSNumber *)errorCode {
    return _code;
}

- (nullable NSDictionary *)errorInfo {
    return nil;
}

- (nonnull NSString *)errorString {
    return _message;
}

//MARK: -UADSWebViewEventConvertible
- (nonnull id<UADSWebViewEvent>)convertToEvent {
    return [UADSWebViewEventBase newWithCategory: self.errorDomain
                                       withEvent: _errorCategory
                                      withParams: [self getEventParams]];
}

- (NSArray *)getEventParams {
    NSMutableArray *paramsArray = [NSMutableArray new];

    if (_meta) {
        NSString *safePlacementID = _meta.placementID ? : @"NULL_PLACEMENT_ID";
        [paramsArray addObject: safePlacementID];
    }

    if (_meta.queryID) {
        [paramsArray addObject: _meta.queryID];
    }

    [paramsArray addObjectsFromArray: self.errorParams];
    return paramsArray;
}

//MARK: - Convenience constructors.
+ (instancetype)newLoadErrorUsingMetaData: (GMAAdMetaData *)meta
                                 andError: (NSError *)error {
    return [self newFromError: error
                  andMetaData: meta
                  andCategory: @"LOAD_ERROR"];
}

+ (instancetype)newShowErrorWithMeta: (GMAAdMetaData *)meta
                           withError: (id<UADSError>)error {
    NSString *event = meta.type == GADQueryInfoAdTypeRewarded ? @"REWARDED_SHOW_ERROR" : @"INTERSTITIAL_SHOW_ERROR";

    return [self newFromError: error
                  andMetaData: meta
                  andCategory: event];
}

+ (instancetype)newSignalsError: (id<UADSError>)error {
    return [self newFromError: error
                  andMetaData: nil
                  andCategory: @"SIGNALS_ERROR"];
}

+ (instancetype)newInternalSignalsError {
    return [self newInternalWithMessage: kGMAInternalSignalsErrorMessage
                            andMetaData: nil
                            andCategory: @"INTERNAL_SIGNALS_ERROR"];
}

+ (instancetype)newNonSupportedLoader: (GMAAdMetaData *)meta {
    NSString *adType = [self adTypeAsString: meta.type];
    NSString *message = [NSString stringWithFormat: kGMANonSupportedLoaderFormat, adType];

    return [self newInternalLoadError: meta
                          withMessage: message];
}

+ (instancetype)newNonSupportedPresenter: (GMAAdMetaData *)meta {
    NSString *adType = [self adTypeAsString: meta.type];
    NSString *message = [NSString stringWithFormat: kGMANonSupportedPresenterFormat, adType];

    return [self newInternalWithMessage: message
                            andMetaData: meta
                            andCategory: @"INTERNAL_SHOW_ERROR"];
}

+ (instancetype)newNoAdFoundToShowForMeta: (GMAAdMetaData *)meta {
    NSString *adType = [self adTypeAsString: meta.type];
    NSString *message = [NSString stringWithFormat: kGMANoAdFoundFormat, adType];

    return [self newInternalWithMessage: message
                            andMetaData: meta
                            andCategory: @"NO_AD_ERROR"];
}

+ (instancetype)newCannotCreateAd: (GMAAdMetaData *)meta; {
    NSString *adType = [self adTypeAsString: meta.type];
    NSString *message = [NSString stringWithFormat: kGMACannotCreateAdFormat, adType];

    return [self newInternalLoadError: meta
                          withMessage: message];
}

+ (instancetype)newInternalLoadQueryNotFound: (GMAAdMetaData *)meta {
    NSString *message = [NSString stringWithFormat: kGMAQueryNotFoundFormat, meta.placementID];

    return [self newInternalWithMessage: message
                            andMetaData: meta
                            andCategory: @"QUERY_NOT_FOUND_ERROR"];
}

+ (instancetype)newInternalLoadAdInfoNotFound: (GMAAdMetaData *)meta {
    NSString *message = [NSString stringWithFormat: kGMAInfoNotCreatedFormat, meta.placementID];

    return [self newInternalWithMessage: message
                            andMetaData: meta
                            andCategory: @"AD_INFO_ERROR"];
}

+ (instancetype)newInternalLoadError: (GMAAdMetaData *)meta
                         withMessage: (NSString *)message {
    return [self newInternalWithMessage: message
                            andMetaData: meta
                            andCategory: @"INTERNAL_LOAD_ERROR"];
}

+ (NSString *)adTypeAsString: (GADQueryInfoAdType)type {
    return type == GADQueryInfoAdTypeInterstitial ? @"Interstitial" : @"Rewarded";
}

+ (NSArray *)errorParamsFromError: (id)error {
    NSString *safeError = uads_extractErrorString(error) ? : @"NOT_NSERROR_NOR_NSSTRING";
    NSNumber *safeCode = uads_extractErrorCode(error) ? : @-1;

    return @[safeError, safeCode];
}

@end
