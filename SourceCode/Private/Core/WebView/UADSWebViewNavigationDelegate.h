#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UADSWebViewNavigationDelegate : NSObject <WKNavigationDelegate>
+ (UADSWebViewNavigationDelegate *)sharedInstance;
@end

NS_ASSUME_NONNULL_END
