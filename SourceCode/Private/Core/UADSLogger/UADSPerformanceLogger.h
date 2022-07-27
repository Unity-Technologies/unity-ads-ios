#import <Foundation/Foundation.h>
#import "UADSLogger.h"
NS_ASSUME_NONNULL_BEGIN

@protocol UADSPerformanceLogger

- (void)startMeasureForSystem: (NSString *)system;
- (void)endMeasureForSystem: (NSString *)system;

@end

@interface UADSPerformanceLoggerBase : NSObject<UADSPerformanceLogger>

+ (instancetype)newWithLogger: (id<UADSLogger>)logger;


@end

NS_ASSUME_NONNULL_END
