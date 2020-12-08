@protocol UADSTokenStorageEventProtocol <NSObject>

- (void) sendQueueEmpty;
- (void) sendTokenAccessIndex:(NSNumber*)index;

@end
