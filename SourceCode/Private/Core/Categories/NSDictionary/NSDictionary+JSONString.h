#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (JSONString)
- (NSString *)       uads_jsonEncodedString;
- (NSData *_Nullable)uads_jsonData;
- (NSString *)       uads_queryString;
- (BOOL)             uads_isEmpty;
@end

NS_ASSUME_NONNULL_END
