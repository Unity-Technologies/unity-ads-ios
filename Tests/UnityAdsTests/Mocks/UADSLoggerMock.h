#import <Foundation/Foundation.h>
#import "UADSLogger.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSLoggerMock : NSObject<UADSLogger>
@property (nonatomic, assign) UADSLogLevel currentLogLevel;
@end

NS_ASSUME_NONNULL_END
