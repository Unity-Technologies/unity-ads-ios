#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (WindowScene)
+ (UIWindowScene *)currentWindowScene API_AVAILABLE(ios(13.0));
@end

NS_ASSUME_NONNULL_END
