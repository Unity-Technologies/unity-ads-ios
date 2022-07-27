#import <Foundation/Foundation.h>
#import "UADSCurrentTimestamp.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSCurrentTimestampMock : NSObject <UADSCurrentTimestamp>
@property (nonatomic, assign) CFTimeInterval currentTime;
@property (nonatomic, assign) CFTimeInterval epochCurrentTime;

+ (NSNumber *)mockedDuration;
@end

NS_ASSUME_NONNULL_END
