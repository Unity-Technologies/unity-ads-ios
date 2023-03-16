#import "UADSSCARSignalReaderMock.h"

@interface UADSSCARSignalReaderMock()

@property (nonatomic) UADSSuccessCompletion completion;

@end

@implementation UADSSCARSignalReaderMock

- (instancetype)init {
    SUPER_INIT;
    self.signals = [NSDictionary new];
    return self;
}

- (void)requestSCARSignalsWithIsAsync:(BOOL)async completion:(UADSSuccessCompletion _Nullable)completion {
    _callHistoryCount += 1;
    if (_shouldAutoComplete) {
        completion([self.signals copy]);
        return;
    }
    _completion = completion;
}

-(void)triggerSignalCompletion {
    GUARD(_completion);
    _completion([self.signals copy]);
}

@end
