#import <Foundation/Foundation.h>
#import "NSLocale + PriceDictionary.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSLocale (CustomInit)
+ (instancetype)  newForUS;
+ (NSDictionary *)defaultTestData;
@end

NS_ASSUME_NONNULL_END
