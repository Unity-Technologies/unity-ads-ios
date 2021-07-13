#import "EventSenderMock.h"
#import "UADSTools.h"

@implementation EventSenderMock


- (instancetype)init
{
    SUPER_INIT;
    self.events = [NSArray new];
    return self;
}

- (void)sendEvent: (nonnull id<UADSWebViewEvent>)event {
    _events = [_events arrayByAddingObject: event];
}

@end
