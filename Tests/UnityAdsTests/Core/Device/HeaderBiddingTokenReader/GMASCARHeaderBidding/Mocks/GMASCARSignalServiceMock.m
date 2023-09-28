#import "GMASCARSignalServiceMock.h"

@interface GMASCARSignalServiceMock()
@property (nonatomic, strong) UADSGMAScarSignalsCompletion *completion;
@end

@implementation GMASCARSignalServiceMock

- (void)getSCARSignals:(nonnull NSArray<UADSScarSignalParameters *> *)signalParameters completion:(nonnull UADSGMAScarSignalsCompletion *)completion {
    self.requestedSignals = signalParameters;
    self.completion = completion;
}

- (nullable GADRequestBridge *)getAdRequestFor:(nonnull GMAAdMetaData *)meta error:(id<UADSError>  _Nullable __autoreleasing * _Nullable)error {
    return nil;
}

- (void)callSuccessCompletion:(UADSSCARSignals *)result {
    [self.completion success:result];
}

- (void)callErrorCompletion:(id<UADSError>)error {
    [self.completion error:error];
}

@end
