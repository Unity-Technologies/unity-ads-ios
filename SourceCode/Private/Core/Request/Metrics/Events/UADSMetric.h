#import "UADSDictionaryConvertible.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSMetric : NSObject <UADSDictionaryConvertible>
+ (instancetype)newWithName: (NSString *)name value: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags;

- (instancetype)updatedWithValue: (nullable NSNumber *)value;
@end



NS_ASSUME_NONNULL_END
