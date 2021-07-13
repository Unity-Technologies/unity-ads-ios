#import <Foundation/Foundation.h>
#import "UADSGenericError.h"
#import "UADSWebViewEvent.h"
#import "GMAAdMetaData.h"
NS_ASSUME_NONNULL_BEGIN

static NSString *const kGMANonSupportedLoaderFormat = @"Cannot find loader of type: %@";
static NSString *const kGMANonSupportedPresenterFormat = @"Cannot find presenter of type: %@";
static NSString *const kGMANoAdFoundFormat = @"%@ is not found. Possibly it wasn't loaded. Cannot show ad.";
static NSString *const kGMACannotCreateAdFormat = @"%@ ad was nil. There was a problem creating the ad.";
static NSString *const kGMAQueryNotFoundFormat = @"Query Info is not found for placementID %@. Possibly QueryId and RequestId don't match";
static NSString *const kGMAInfoNotCreatedFormat =  @"GADInfo was nil or invalid for placementID %@. Possibly QueryId and RequestId don't match";

static NSString *const kGMAInternalSignalsErrorMessage =  @"Could not collect signals. Probably SCAR is not supported";




@interface GMAError : NSObject<UADSError, UADSWebViewEventConvertible>
+ (instancetype)newCannotCreateAd: (GMAAdMetaData *)meta;
+ (instancetype)newNonSupportedLoader: (GMAAdMetaData *)meta;
+ (instancetype)newNonSupportedPresenter: (GMAAdMetaData *)meta;
+ (instancetype)newNoAdFoundToShowForMeta: (GMAAdMetaData *)meta;
+ (instancetype)newShowErrorWithMeta: (GMAAdMetaData *)meta
                           withError: (id<UADSError>)error;
+ (instancetype)newInternalLoadQueryNotFound: (GMAAdMetaData *)meta;

+ (instancetype)newInternalLoadAdInfoNotFound: (GMAAdMetaData *)meta;
+ (instancetype)newLoadErrorUsingMetaData: (GMAAdMetaData *)meta
                                 andError: (NSError *)error;
+ (instancetype)newSignalsError: (id<UADSError>)error;
+ (instancetype)newInternalSignalsError;
@end

NS_ASSUME_NONNULL_END
