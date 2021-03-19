#import "UADSWebViewInvoker.h"
#import "USRVInitializationNotificationCenter.h"
NS_ASSUME_NONNULL_BEGIN

@interface WebViewInvokerQueueDecorator: NSObject<UADSWebViewInvoker, USRVInitializationDelegate>
+(instancetype)newWithDecorated: (id<UADSWebViewInvoker>)decorated
          andNotificationCenter: (id<USRVInitializationNotificationCenterProtocol>)center ;
@end

NS_ASSUME_NONNULL_END
