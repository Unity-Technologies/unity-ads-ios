#import "UADSWebViewEventSender.h"
#import "USRVWebViewApp.h"

@implementation UADSWebViewEventSenderBase

- (void)sendEvent: (nonnull id<UADSWebViewEvent>)event {
    [[USRVWebViewApp getCurrentApp] sendEvent: event.eventName
                                     category: event.categoryName
                                       params: event.params];
}

@end
