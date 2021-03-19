#import "USRVWebViewMethodInvokeOperation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, USRVWebViewAsyncOperationStatus) {
    kUSRVWebViewAsyncOperationStatusOK,
    kUSRVWebViewAsyncOperationStatusTimeout,
    kUSRVWebViewAsyncOperationStatusError,
    kUSRVWebViewAsyncOperationStatusWaiting,
    kUSRVWebViewAsyncOperationStatusIdle,
};

typedef void (^USRVWebViewAsyncOperationCompletion)(USRVWebViewAsyncOperationStatus, NSString* callbackStatusValue);


@interface USRVWebViewAsyncOperation: NSObject


+(instancetype)newWithMethod: (NSString *)webViewMethod
                webViewClass: (NSString *)webViewClass
                  parameters: (NSArray *)parameters
                    waitTime: (int)waitTime;

-(void)execute:(USRVWebViewAsyncOperationCompletion)completion;
@end

NS_ASSUME_NONNULL_END
