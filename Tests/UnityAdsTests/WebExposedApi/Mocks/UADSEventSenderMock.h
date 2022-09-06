
#import <Foundation/Foundation.h>
#import "UADSWebViewEventSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSEventSenderMock : NSObject<UADSWebViewEventSender>
@property (nonatomic, strong) NSArray<id<UADSWebViewEvent> > *receivedEvents;
@end

NS_ASSUME_NONNULL_END
