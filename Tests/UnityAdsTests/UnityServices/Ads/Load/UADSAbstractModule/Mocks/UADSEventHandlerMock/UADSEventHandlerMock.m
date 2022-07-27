#import "UADSEventHandlerMock.h"
#import "UADSTools.h"
@implementation UADSEventHandlerMock

- (instancetype)init {
    SUPER_INIT;
    _errors = [NSMutableDictionary new];
    _onSuccessCalls = [NSMutableDictionary new];
    _startedCalls = [NSMutableDictionary new];
    return self;
}

- (void)catchError: (nonnull UADSInternalError *)error forId: (nonnull NSString *)identifier {
    @synchronized (self) {
        NSArray *err = _errors[identifier] ? : [NSArray array];
        err = [err arrayByAddingObject: error];
        _errors[identifier] = err;
    }
}

- (void)eventStarted: (NSString *)identifier {
    @synchronized (self) {
        _startedCalls[identifier] = @([_startedCalls[identifier] intValue] + 1);
    }
}

- (void)onSuccess: (NSString *)identifier {
    @synchronized (self) {
        _onSuccessCalls[identifier] = @([_onSuccessCalls[identifier] intValue] + 1);
    }
}

@end
