#import <Foundation/Foundation.h>
#import "UADSWebViewEvent.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSWebViewEventSender<NSObject>
- (void)sendEvent: (id<UADSWebViewEvent>)event;
@end

@interface UADSWebViewEventSenderBase : NSObject<UADSWebViewEventSender>

@end

NS_ASSUME_NONNULL_END
