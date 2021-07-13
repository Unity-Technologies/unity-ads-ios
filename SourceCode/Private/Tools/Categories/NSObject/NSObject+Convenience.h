#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Category)
+ (bool)containsMethods: (NSArray<NSString *> *)names;
@end

NS_ASSUME_NONNULL_END
