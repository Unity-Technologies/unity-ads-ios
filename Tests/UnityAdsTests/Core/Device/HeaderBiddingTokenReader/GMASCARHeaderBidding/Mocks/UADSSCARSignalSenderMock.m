#import "UADSSCARSignalSenderMock.h"

@implementation UADSSCARSignalSenderMockData


-(instancetype)initWithUUIDString:(NSString*)uuidString signals:(UADSSCARSignals*)signals {
    SUPER_INIT;
    _uuidString = uuidString;
    _signals = signals;
    return self;
}

@end

@implementation UADSSCARSignalSenderMock

-(instancetype)init {
    SUPER_INIT;
    _callHistory = [NSMutableArray new];
    return self;
}

- (void)sendSCARSignalsWithUUIDString:(NSString * _Nonnull)uuidString signals:(UADSSCARSignals * _Nonnull)signals isAsync:(BOOL)isAsync {
    @synchronized (self) {
        [self.callHistory addObject:[[UADSSCARSignalSenderMockData alloc] initWithUUIDString:uuidString signals:signals]];
        [self.callExpectation fulfill];
    }
}

@end
