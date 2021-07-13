#import "UADSWebViewErrorHandler.h"

@interface UADSWebViewErrorHandler ()
@property (nonatomic, strong) id<UADSWebViewEventSender> eventSender;
@end

@implementation UADSWebViewErrorHandler

+ (instancetype)newWithEventSender: (id)eventSender {
    UADSWebViewErrorHandler *handler = [UADSWebViewErrorHandler new];

    handler.eventSender = eventSender;
    return handler;
}

+ (instancetype)defaultHandler {
    return [self newWithEventSender: [UADSWebViewEventSenderBase new]];
}

- (void)catchError: (nonnull id<UADSError>)error {
    if ([error conformsToProtocol: @protocol(UADSWebViewEventConvertible)]) {
        id<UADSWebViewEventConvertible>event = (id<UADSWebViewEventConvertible>)error;
        [_eventSender sendEvent: [event convertToEvent]];
    }
}

@end
