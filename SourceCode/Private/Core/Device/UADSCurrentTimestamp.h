#import <Foundation/Foundation.h>

@protocol UADSCurrentTimestamp <NSObject>
- (CFTimeInterval)currentTimestamp;
- (NSNumber *)    msDurationFrom: (CFTimeInterval)time;
@end
