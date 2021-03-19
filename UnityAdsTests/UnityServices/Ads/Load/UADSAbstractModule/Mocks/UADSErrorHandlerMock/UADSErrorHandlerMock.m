#import "UADSErrorHandlerMock.h"
#import "UADSTools.h"
@implementation UADSErrorHandlerMock

- (instancetype)init {
    SUPER_INIT;
    self.errors = [NSArray new];
    return self;
}

- (void)catchError:(nonnull UADSInternalError *)error {
    _errors = [_errors arrayByAddingObject: error];
}

@end
