#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSPlistReader <NSObject>

- (NSString *)getStringValueForKey: (NSString *)key;

@end

@interface NSBundle (TypecastGet)<UADSPlistReader>
- (NSString *)getStringValueForKey: (NSString *)key;
+ (NSString *)getBuiltSDKVersion;
+ (NSString *)getFromMainBundleValueForKey: (NSString *)key;
@end

NS_ASSUME_NONNULL_END
