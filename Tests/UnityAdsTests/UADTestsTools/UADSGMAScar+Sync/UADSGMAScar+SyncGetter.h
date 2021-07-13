#import "UADSGMAScar.h"
#import "XCTestAssert+Fail.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSGMAScar (SyncCategory)
- (void)getSignalsSyncWithSuccessTest: (NSArray *)interstitialList
                      andRewardedList: (NSArray *)rewardedList
                              forTest: (XCTestCase *)testCase
                   andErrorCompletion: (UADSErrorCompletion)errorCompletion;

- (void)getSignalsSyncWithErrorTest: (NSArray *)interstitialList
                    andRewardedList: (NSArray *)rewardedList
                            forTest: (XCTestCase *)testCase
                      andCompletion: (UADSSuccessCompletion)success;

- (void)getSignalsSyncWithTestCase: (XCTestCase *)testCase
               andInterstitialList: (NSArray *)interstitialList
                   andRewardedList: (NSArray *)rewardedList;

- (void)loadSuccessSyncWithTestCase: (XCTestCase *)testCase
                        andMetaData: (GMAAdMetaData *)meta
               andSuccessCompletion: (UADSSuccessCompletion)completion;

- (void)loadErrorSyncWithTestCase: (XCTestCase *)testCase
                      andMetaData: (GMAAdMetaData *)meta
               andErrorCompletion: (UADSErrorCompletion)completion;
@end

NS_ASSUME_NONNULL_END
