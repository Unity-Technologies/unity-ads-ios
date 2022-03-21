#import "UADSOverlayError.h"
#import <StoreKit/StoreKit.h>

@protocol UADSOverlayEventProtocol <NSObject>

- (void)sendOverlayWillStartPresentation: (SKOverlay *)overlay API_AVAILABLE(ios(14.0));
- (void)sendOverlayDidFinishPresentation: (SKOverlay *)overlay API_AVAILABLE(ios(14.0));
- (void)sendOverlayWillStartDismissal: (SKOverlay *)overlay API_AVAILABLE(ios(14.0));
- (void)sendOverlayDidFinishDismissal: (SKOverlay *)overlay API_AVAILABLE(ios(14.0));
- (void)sendOverlayDidFailToLoad: (SKOverlay *)overlay error: (UADSOverlayError)error message: (NSString *)message API_AVAILABLE(ios(14.0));
- (void)sendOverlayDidFailToLoad: (UADSOverlayError)error;

@end
