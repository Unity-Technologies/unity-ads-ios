#import "GADQueryInfoBridge.h"
#import "UADSGenericCompletion.h"
#import "GMAQueryInfoReader.h"
#import "GADRequestBridge.h"
#import "GMAAdMetaData.h"
NS_ASSUME_NONNULL_BEGIN

typedef UADSGenericCompletion<NSString *>                       UADSGMASCARCompletion;

//Represents Dictionary where a key is a placementID and value is GADQueryInfoBridge
typedef NSMutableDictionary<NSString *, GADQueryInfoBridge *>   GADQueryInfoSource;

@protocol GMAQuerySignalReader<NSObject>
/// Returns a SCAR signal as NSString* for an AdType and placementID
/// Returns id<UADSError> if an error occurs.
/// @param adType AdType
/// @param placementId NSString *
/// @param completionHandler UADSGMAInfoScarCompletion
- (void)getSignalOfAdType: (GADQueryInfoAdType)adType
           forPlacementId: (NSString *)placementId
               completion: (UADSGMASCARCompletion *)completionHandler;
@end

@protocol GADRequestFactory<NSObject>

/// Creates GADRequest wrapped into GADRequestBridge proxy using placementID and adString
/// @param meta GMAAdMetaData *
/// @param error id<UADSError>
- (nullable GADRequestBridge *)getAdRequestFor: (GMAAdMetaData *)meta
                                         error: (id<UADSError>_Nullable *_Nullable)error;
@end


@protocol GMASignalService<NSObject, GMAQuerySignalReader, GADRequestFactory>

@end

/**
    Class that retrieves SCARSignals reflectively. Internally it creates GADQueryInfoBridge and saves them for each placementID, so they can be retrieved upon request. In addition  GADQueryInfoBridge is used when GADRequestBridge created.
 */
@interface GMABaseQuerySignalReader : NSObject<GMASignalService>
- (instancetype)__unavailable init;
+ (instancetype)newWithInfoReader: (id<GMAQueryInfoReader>)reader;

// exposed for tests
- (GADQueryInfoBridge *)queryForPlacementID: (NSString *)placementID;
@end

NS_ASSUME_NONNULL_END
