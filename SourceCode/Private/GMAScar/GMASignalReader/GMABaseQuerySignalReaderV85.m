#import "GMABaseQuerySignalReaderV85.h"
#import "GADRequestBridgeV85.h"
#import "GADExtrasBridge.h"
#import "GMAError.h"

@interface GMABaseQuerySignalReaderV85 ()
@property (strong, nonatomic) id<GMAQueryInfoReader> queryInfoReader;
@end

@implementation GMABaseQuerySignalReaderV85

+ (BOOL)isSupported {
    return [GADRequestBridgeV85 exists] && [GADExtrasBridge exists];
}

+ (instancetype)newWithInfoReader: (id<GMAQueryInfoReader>)reader {
    return [[self alloc] initWithInfoReader: reader];
}

- (instancetype)initWithInfoReader: (id<GMAQueryInfoReader>)reader {
    SUPER_INIT;
    self.queryInfoReader = reader;
    return self;
}

- (void)getSignalOfAdType:(GADQueryInfoAdType)adType forPlacementId:(nonnull NSString *)placementId completion:(nonnull UADSGMASCARCompletion *)completionHandler {

    id successHandler = ^(GADQueryInfoBridge *_Nullable info) {
        [completionHandler success: info.query];
    };
    
    id errorHandler = ^(id<UADSError> _Nonnull error) {
        [completionHandler error: [GMAError newSignalsError: error ]];
    };
    
    GADQueryInfoBridgeCompletion *completion = [GADQueryInfoBridgeCompletion newWithSuccess: successHandler
                                                                                   andError: errorHandler];
    [self.queryInfoReader getQueryInfoOfFormat: adType
                                    completion: completion];
}

- (nullable GADRequestBridge *)getAdRequestFor:(nonnull GMAAdMetaData *)meta error:(id<UADSError>  _Nullable __autoreleasing * _Nullable)error {
    GADRequestBridgeV85 *request = [GADRequestBridgeV85 getNewRequest];
    request.adString = meta.adString;
    return request;
}

@end
