#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Headers)
+ (NSDictionary<NSString *, NSArray *> *)uads_getHeadersMap: (NSArray *)headers;
+ (NSArray<NSArray<NSString *> *> *)uads_getHeadersArray: (NSDictionary<NSString *, NSString *> *)headersMap;
+ (NSDictionary<NSString *, NSString *> *)uads_getRequestHeaders: (NSDictionary<NSString *, NSArray *> *)headers;
@end

NS_ASSUME_NONNULL_END
