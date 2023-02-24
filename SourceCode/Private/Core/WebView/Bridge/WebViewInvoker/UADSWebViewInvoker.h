#import "UADSInternalError.h"
#import "UADSBaseOptions.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^UADSWebViewInvokerErrorCompletion)(UADSInternalError *__nullable error);
typedef void (^UADSWebViewInvokerCompletion)(void);

static NSString *const kUnityAdsShowErrorKey = @"error";
static NSString *const kUnityAdsShowErrorMessageKey = @"errorMessage";
static NSString *const kWebViewClassName = @"webview";


@protocol UADSWebViewInvokerOperation <NSObject, UADSDictionaryConvertible>
- (NSString *)methodName;
- (NSString *)className;
@end

@protocol UADSWebViewInvoker <NSObject>

- (void)         invokeOperation: (id<UADSWebViewInvokerOperation>)operation
                  withCompletion: (UADSWebViewInvokerCompletion)completion
              andErrorCompletion: (UADSWebViewInvokerErrorCompletion)errorCompletion;

@end

@interface UADSWebViewInvokerImp : NSObject<UADSWebViewInvoker>
+ (instancetype)newWithWaitingTime: (int)waitingTime;
@end

NS_ASSUME_NONNULL_END
