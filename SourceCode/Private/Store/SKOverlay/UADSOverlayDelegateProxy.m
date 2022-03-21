#import "UADSOverlayDelegateProxy.h"
#import "UADSOverlayError.h"

@interface UADSOverlayDelegateProxy ()
@property (nonatomic, weak) id<UADSOverlayEventProtocol> handler;
@end

@implementation UADSOverlayDelegateProxy

- (instancetype)initWithEventHandler: (id<UADSOverlayEventProtocol>)handler {
    SUPER_INIT
        _handler = handler;

    return self;
}

- (void)storeOverlay: (SKOverlay *)overlay didFailToLoadWithError: (NSError *)error  API_AVAILABLE(ios(14.0)) {
    [self.handler sendOverlayDidFailToLoad: overlay
                                     error: kOverlayNoLoad
                                   message: [error localizedDescription]];
}

- (void)storeOverlay: (SKOverlay *)overlay willStartPresentation: (SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)) {
    [self.handler sendOverlayWillStartPresentation: overlay];
}

- (void)storeOverlay: (SKOverlay *)overlay didFinishPresentation: (SKOverlayTransitionContext *)transitionContext API_AVAILABLE(ios(14.0)) {
    [self.handler sendOverlayDidFinishPresentation: overlay];
}

- (void)storeOverlay: (SKOverlay *)overlay willStartDismissal: (SKOverlayTransitionContext *)transitionContext API_AVAILABLE(ios(14.0)) {
    [self.handler sendOverlayWillStartDismissal: overlay];
}

- (void)storeOverlay: (SKOverlay *)overlay didFinishDismissal: (SKOverlayTransitionContext *)transitionContext API_AVAILABLE(ios(14.0)) {
    [self.handler sendOverlayDidFinishDismissal: overlay];
}

@end
