#import "UADSDictionaryConvertible.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSMetric : NSObject <UADSDictionaryConvertible>
+ (instancetype)newWithName: (NSString *)name value: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
@end

NS_ASSUME_NONNULL_END
