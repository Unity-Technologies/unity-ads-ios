#import "UADSOverlayEventProtocol.h"
#import "UADSWebViewEventSender.h"

@interface UADSOverlayEventHandler : NSObject<UADSOverlayEventProtocol>

- (id)initWithEventSender: (id<UADSWebViewEventSender>)eventSender;

@end
