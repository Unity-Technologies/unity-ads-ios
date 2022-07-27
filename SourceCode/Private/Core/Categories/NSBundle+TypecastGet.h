#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSPlistReader <NSObject>

- (NSString *)uads_getStringValueForKey: (NSString *)key;

@end

@interface NSBundle (TypecastGet)<UADSPlistReader>
- (NSString *)uads_getStringValueForKey: (NSString *)key;
+ (NSString *)uads_getBuiltSDKVersion;
+ (NSString *)uads_getFromMainBundleValueForKey: (NSString *)key;
@end

NS_ASSUME_NONNULL_END
