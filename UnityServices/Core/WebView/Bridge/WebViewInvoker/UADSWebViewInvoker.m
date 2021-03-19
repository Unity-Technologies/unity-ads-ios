#import "UADSWebViewInvoker.h"
#import "USRVWebViewAsyncOperation.h"
#import "UADSTools.h"
#import "UnityAdsShowError.h"

static NSString *const kWebViewShowClassName = @"webview";
static NSString *const kShowStateSenderErrorMessage = @"Failed invoke WebView the method: ";
static NSString *const kCallbackStatusKey = @"cbs";

@interface UADSWebViewInvokerImp()
@property (nonatomic, assign) int waitingTime;
@end

@implementation UADSWebViewInvokerImp

+(instancetype)newWithWaitingTime:(int)waitingTime {
    UADSWebViewInvokerImp *obj = [[self alloc] init];
    obj.waitingTime = waitingTime;
    return obj;
}


- (void)invokeOperation:(id<UADSWebViewInvokerOperation>)operation
         withCompletion:(UADSWebViewInvokerCompletion)completion
     andErrorCompletion:(UADSWebViewInvokerErrorCompletion)errorCompletion {
    
    USRVWebViewAsyncOperation* asyncOperation = [USRVWebViewAsyncOperation newWithMethod: operation.methodName
                                                                            webViewClass: kWebViewShowClassName
                                                                              parameters: @[operation.dictionary]
                                                                                waitTime: _waitingTime];
    [asyncOperation execute:^(USRVWebViewAsyncOperationStatus status, NSString *callbackStatus) {
        [self processOperationResult: status
                  withCallbackStatus: callbackStatus
                         ofOperation: operation
                      withCompletion: completion
                  andErrorCompletion: errorCompletion];
    }];
}

- (void)processOperationResult: (USRVWebViewAsyncOperationStatus) status
            withCallbackStatus: (NSString *)callbackStatus
                   ofOperation: (id<UADSWebViewInvokerOperation>)operation
                withCompletion: (UADSWebViewInvokerCompletion)completion
            andErrorCompletion: (UADSWebViewInvokerErrorCompletion)errorCompletion {
    UADSInternalError *internalError = [self convertResponseIntoErrorIfFalse: status
                                                          withCallbackStatus: callbackStatus
                                                                 ofOperation: operation];
    if (internalError) {
        errorCompletion(internalError);
    } else {
        completion();
    }
}

-(UADSInternalError *)convertResponseIntoErrorIfFalse: (USRVWebViewAsyncOperationStatus) status
                                   withCallbackStatus: (NSString *)callbackStatus
                                          ofOperation: (id<UADSWebViewInvokerOperation>)operation {
    UADSInternalErrorWebViewType errorReason = [self mapToInternalErrorEnum: status];
    GUARD_OR_NIL((errorReason > -1));
    NSString *errorMessage = [self errorMessageForOperation: operation];
    
    UADSInternalError *newError = [UADSInternalError newWithErrorCode: kUADSInternalErrorWebView
                                                            andReason: errorReason
                                                           andMessage: errorMessage];
    if (callbackStatus) {
        newError.errorInfo = @{kCallbackStatusKey: callbackStatus};
    }
    
    return newError;
}

-(UADSInternalErrorWebViewType)mapToInternalErrorEnum:(USRVWebViewAsyncOperationStatus) status {
    if (status == kUSRVWebViewAsyncOperationStatusOK) {
        return -1;
    }
    
    if (status == kUSRVWebViewAsyncOperationStatusTimeout) {
        return kUADSInternalErrorWebViewTimeout;
    } else {
       return kUADSInternalErrorWebViewInternal;
    }
 
}

-(NSString *)errorMessageForOperation: (id<UADSWebViewInvokerOperation>)operation {
    return [NSString stringWithFormat:@"%@ %@",kShowStateSenderErrorMessage, operation.methodName];
}

@end
