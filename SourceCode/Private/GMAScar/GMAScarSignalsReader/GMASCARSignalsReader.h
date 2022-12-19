#import "UADSGenericCompletion.h"
#import "GMAQuerySignalReader.h"

NS_ASSUME_NONNULL_BEGIN

//Represents Dictionary of signals where key is a placement ID and value is a scar signal.
typedef NSDictionary<NSString *, NSString *>       UADSSCARSignals;
typedef UADSGenericCompletion<UADSSCARSignals *>   UADSGMAScarSignalsCompletion;

@protocol GMASCARSignalsReader<NSObject>
- (void)getSCARSignalsUsingInterstitialList: (NSArray *)interstitialList
                            andRewardedList: (NSArray *)rewardedList
                                 completion: (UADSGMAScarSignalsCompletion *)completion;
@end

@protocol GMASCARSignalService<NSObject, GMASCARSignalsReader, GADRequestFactory>;
@end

/**
    Class that encapsulates the logic of retrieving SCAR signals for @b interstitialList and  @b rewardedList`.

    Internally will run two loops for each list to call @b GMASignalService for each placement ID.

    Once the signals are collected will call completion handler with @b UADSScarSignals

   @note: Will generate an error if no signals are able to be generated, or all requests to GMA api failed
 */
@interface GMABaseSCARSignalsReader : NSObject<GMASCARSignalService>
+ (instancetype)newWithSignalService: (id<GMASignalService>)signalService;
@end

NS_ASSUME_NONNULL_END
