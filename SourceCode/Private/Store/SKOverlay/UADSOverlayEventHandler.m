#import "UADSOverlayEventHandler.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"
#import "UADSOverlayWebViewEvent.h"


@interface UADSOverlayEventHandler ()
@property (nonatomic, strong) id<UADSWebViewEventSender>eventSender;
@end

@implementation UADSOverlayEventHandler

- (id)initWithEventSender: (id<UADSWebViewEventSender>)eventSender {
    SUPER_INIT
        _eventSender = eventSender;

    return self;
}

- (void)sendOverlayDidFailToLoad: (UADSOverlayError)error {
    [self sendOverlayDidFailToLoad: error
                           message: nil];
}

- (void)sendOverlayDidFailToLoad: (SKOverlay *)overlay error: (UADSOverlayError)error message: (NSString *)message API_AVAILABLE(ios(14.0)) {
    [self sendOverlayDidFailToLoad: error
                           message: message];
}

- (void)sendOverlayDidFailToLoad: (UADSOverlayError)error message: (NSString *)message {
    [self.eventSender sendEvent: [UADSOverlayWebViewEvent newDidFailToLoadWithParams: @[UADSStringFromOverlayError(error), message ? : @""]]];
}

- (void)sendOverlayDidFinishDismissal: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    [self.eventSender sendEvent: [UADSOverlayWebViewEvent newDidFinishDismissal]];
}

- (void)sendOverlayDidFinishPresentation: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    [self.eventSender sendEvent: [UADSOverlayWebViewEvent newDidFinishPresentation]];
}

- (void)sendOverlayWillStartDismissal: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    [self.eventSender sendEvent: [UADSOverlayWebViewEvent newWillStartDismissal]];
}

- (void)sendOverlayWillStartPresentation: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    [self.eventSender sendEvent: [UADSOverlayWebViewEvent newWillStartPresentation]];
}

@end
