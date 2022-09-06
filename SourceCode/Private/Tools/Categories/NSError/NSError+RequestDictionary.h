#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (RequestDictionary)
+ (instancetype)errorWithFailureDictionary: (NSDictionary *)failure;
@end

NS_ASSUME_NONNULL_END
