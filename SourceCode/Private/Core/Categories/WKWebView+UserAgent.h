#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (UserAgent)
+ (NSString *)uads_getUserAgentSync;
@end

NS_ASSUME_NONNULL_END
