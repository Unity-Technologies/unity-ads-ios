#import <UIKit/UIKit.h>
#import "UADSEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSLoadMetric : UADSMetric

+ (instancetype)newEventStarted: (UADSEventHandlerType)type tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newEventSuccess: (UADSEventHandlerType)type time: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newEventFailed: (UADSEventHandlerType)type time: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags;

@end

NS_ASSUME_NONNULL_END
