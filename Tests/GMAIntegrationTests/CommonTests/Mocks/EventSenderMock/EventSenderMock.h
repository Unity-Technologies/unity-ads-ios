#import "UADSWebViewEventSender.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EventSenderMock : NSObject<UADSWebViewEventSender>
@property (nonatomic, strong) NSArray<id<UADSWebViewEvent> > *events;
@end

NS_ASSUME_NONNULL_END
