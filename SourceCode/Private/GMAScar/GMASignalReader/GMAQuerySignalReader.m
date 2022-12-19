#import "GMAQuerySignalReader.h"
#import "GMAError.h"
#import "UADSTools.h"

static NSString *kGMABaseQuerySignalReaderQueryNotFound = @"ERROR: Cannot find query for placement";
static NSString *kGMABaseQuerySignalReaderQueryInvalidInfo = @"ERROR: Cannot instantiate GADAdInfo object. Cannot load ad.";

@interface GMABaseQuerySignalReader ()
@property (strong, nonatomic) id<GMAQueryInfoReader> queryInfoReader;
@property (strong, nonatomic) GADQueryInfoSource *queryInfoSource;
@end

@implementation GMABaseQuerySignalReader

+ (instancetype)newWithInfoReader: (id<GMAQueryInfoReader>)reader {
    return [[self alloc] initWithInfoReader: reader];
}

- (instancetype)initWithInfoReader: (id<GMAQueryInfoReader>)reader {
    SUPER_INIT;
    self.queryInfoReader = reader;
    self.queryInfoSource = [[GADQueryInfoSource alloc] init];
    return self;
}

- (void)getSignalOfAdType: (GADQueryInfoAdType)adType
           forPlacementId: (nonnull NSString *)placementId
               completion: (nonnull UADSGMASCARCompletion *)completionHandler {
    __weak typeof(self) weakSelf = self;

    id successHandler = ^(GADQueryInfoBridge *_Nullable info) {
        [weakSelf setQuery: info
            forPlacementID: placementId];

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

- (void)  setQuery: (GADQueryInfoBridge *)query
    forPlacementID: (NSString *)placementID {
    [self.queryInfoSource setObject: query
                             forKey: placementID];
}

- (GADQueryInfoBridge *)queryForPlacementID: (NSString *)placementID {
    return [self.queryInfoSource objectForKey: placementID];
}

- (GADRequestBridge *)getAdRequestFor: (GMAAdMetaData *)meta
                                error: (id<UADSError>  _Nullable __autoreleasing *)error {
    GADQueryInfoBridge *queryInfo = [self.queryInfoSource objectForKey: meta.placementID];

    if (!queryInfo) {
        CHECK_POINTER_AND_ASSIGN_OBJECT(error, [GMAError newInternalLoadQueryNotFound: meta])
        return nil;
    }

    GADAdInfoBridge *adInfoObj = [GADAdInfoBridge newWithQueryInfo: queryInfo
                                                          adString: meta.adString];


    if (!adInfoObj.isValid) {
        CHECK_POINTER_AND_ASSIGN_OBJECT(error, [GMAError newInternalLoadAdInfoNotFound: meta])
        return nil;
    }

    GADRequestBridge *request = [GADRequestBridge getNewRequest];

    request.adInfo = adInfoObj;
    return request;
}

@end
