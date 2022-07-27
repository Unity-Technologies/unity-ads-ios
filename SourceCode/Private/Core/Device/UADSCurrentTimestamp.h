#import <Foundation/Foundation.h>

@protocol UADSCurrentTimestamp <NSObject>
- (CFTimeInterval)currentTimestamp;
- (NSTimeInterval)epochSeconds;
- (NSNumber *)    msDurationFrom: (CFTimeInterval)time;
@end
