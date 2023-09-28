#import "GMASCARSignalsReaderMock.h"

@interface GMASCARSignalsReaderMock ()
@property (nonatomic, strong) UADSGMAScarSignalsCompletion *completion;
@end

@implementation GMASCARSignalsReaderMock

- (void)emulateReturnOfAnEmptyDictionary {
    [self.completion success: [UADSSCARSignals new]];
}

- (void)emulateReturnOfNil {
    [self.completion success: nil];
}

- (void)emulateReturnOfADictionary: (UADSSCARSignals *)dictionary {
    [self.completion success: dictionary];
}

- (void)getSCARSignals:(nonnull NSArray<UADSScarSignalParameters *> *)signalParameters completion:(nonnull UADSGMAScarSignalsCompletion *)completion {
    self.completion = completion;
}

@end
