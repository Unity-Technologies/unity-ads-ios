#import "UADSGenericCompletion.h"
#import "GMASCARSignalsReader.h"

NS_ASSUME_NONNULL_BEGIN
typedef UADSGenericCompletion<NSString *> UADSGMAEncodedSignalsCompletion;

@protocol GMAEncodedSCARSignalsReader<NSObject>
- (void)getSCARSignalsUsingInterstitialList: (NSArray *)interstitialList
                            andRewardedList: (NSArray *)rewardedList
                                 completion: (UADSGMAEncodedSignalsCompletion *)completion;
@end


/**
   Extends the logic of @b GMAScarSignalsReader by providing encoding returned value into a json string.
 */
@interface GMASCARSignalsReaderDecorator : NSObject<GMAEncodedSCARSignalsReader>
+ (instancetype)newWithSignalService: (id<GMASCARSignalsReader>)signalService;
@end

NS_ASSUME_NONNULL_END
