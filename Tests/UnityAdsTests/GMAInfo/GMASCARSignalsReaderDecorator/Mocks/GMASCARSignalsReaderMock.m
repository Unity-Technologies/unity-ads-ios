#import "GMASCARSignalsReaderMock.h"

@interface GMASCARSignalsReaderMock ()
@property (nonatomic, strong) UADSGMAScarSignalsCompletion *completion;
@end

@implementation GMASCARSignalsReaderMock

- (void)getSCARSignalsUsingInterstitialList: (nonnull NSArray *)interstitialList
                            andRewardedList: (nonnull NSArray *)rewardedList
                                 completion: (nonnull UADSGMAScarSignalsCompletion *)completion {
    self.completion = completion;
}

- (void)emulateReturnOfAnEmptyDictionary {
    [self.completion success: [UADSSCARSignals new]];
}

- (void)emulateReturnOfNil {
    [self.completion success: nil];
}

- (void)emulateReturnOfADictionary: (UADSSCARSignals *)dictionary {
    [self.completion success: dictionary];
}

@end
