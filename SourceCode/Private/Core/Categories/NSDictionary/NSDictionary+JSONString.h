#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (JSONString)
- (NSString *)       jsonEncodedString;
- (NSData *_Nullable)jsonData;
- (NSString *)       queryString;
- (BOOL)             isEmpty;
@end

NS_ASSUME_NONNULL_END
