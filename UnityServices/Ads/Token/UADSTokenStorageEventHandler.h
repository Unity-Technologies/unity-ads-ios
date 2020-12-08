#import "UADSTokenStorageEventProtocol.h"

@interface UADSTokenStorageEventHandler : NSObject<UADSTokenStorageEventProtocol>

- (void) sendQueueEmpty;
- (void) sendTokenAccess:(NSNumber*)index;

@end
