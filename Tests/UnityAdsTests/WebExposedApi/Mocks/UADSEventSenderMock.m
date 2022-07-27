#import "UADSEventSenderMock.h"
#import "UADSTools.h"

@implementation UADSEventSenderMock

- (instancetype)init {
    SUPER_INIT;
    self.receivedEvents = [NSArray new];
    return self;
}

- (void)sendEvent:(id<UADSWebViewEvent>)event {
    _receivedEvents = [_receivedEvents arrayByAddingObject: event];
}
@end
