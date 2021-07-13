#import "WebViewInvokerQueueDecorator.h"
#import "USRVSdkProperties.h"

static NSString *const kSDKNotInitializedErrorMessage = @"SDK is not initialized";

@interface BufferObject : NSObject
@property (nonatomic, strong) id<UADSWebViewInvokerOperation> operation;
@property (nonatomic, strong) UADSWebViewInvokerCompletion completion;
@property (nonatomic, strong) UADSWebViewInvokerErrorCompletion errorCompletion;
@end

@implementation BufferObject
@end

@interface WebViewInvokerQueueDecorator ()
@property (nonatomic, strong) id<UADSWebViewInvoker> decorated;
@property (nonatomic, strong) NSMutableArray<BufferObject *> *buffer;
@property (nonatomic, strong) id<USRVInitializationNotificationCenterProtocol> center;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@end

@implementation WebViewInvokerQueueDecorator

+ (instancetype)newWithDecorated: (id<UADSWebViewInvoker>)decorated
           andNotificationCenter: (id<USRVInitializationNotificationCenterProtocol>)center {
    WebViewInvokerQueueDecorator *obj = [WebViewInvokerQueueDecorator new];

    obj.decorated = decorated;
    obj.buffer = [NSMutableArray new];
    obj.center = center;
    obj.serialQueue = dispatch_queue_create("com.unity.WebViewInvokerQueueDecorator", DISPATCH_QUEUE_SERIAL);
    [center addDelegate: obj];
    return obj;
}

- (void)invokeOperation: (id<UADSWebViewInvokerOperation>)operation
         withCompletion: (UADSWebViewInvokerCompletion)completion
     andErrorCompletion: (UADSWebViewInvokerErrorCompletion)errorCompletion {
    switch (USRVSdkProperties.getCurrentInitializationState) {
        case INITIALIZED_SUCCESSFULLY:
            [self callInvokerWithOperation: operation
                            withCompletion: completion
                        andErrorCompletion: errorCompletion];
            break;

        case NOT_INITIALIZED:
        case INITIALIZING:
            [self saveOperationIntoBuffer: operation
                           withCompletion: completion
                       andErrorCompletion: errorCompletion];
            break;

        case INITIALIZED_FAILED:
            errorCompletion(self.notInitializedError);

        default:
            break;
    }
} /* invokeOperation */

- (void)callInvokerWithOperation: (id<UADSWebViewInvokerOperation>)operation
                  withCompletion: (UADSWebViewInvokerCompletion)completion
              andErrorCompletion: (UADSWebViewInvokerErrorCompletion)errorCompletion {
    [_decorated invokeOperation: operation
                 withCompletion: completion
             andErrorCompletion: errorCompletion];
}

- (void)saveOperationIntoBuffer: (id<UADSWebViewInvokerOperation>)operation
                 withCompletion: (UADSWebViewInvokerCompletion)completion
             andErrorCompletion: (UADSWebViewInvokerErrorCompletion)errorCompletion {
    BufferObject *obj = [self createBufferObjectWithOperation: operation
                                               withCompletion: completion
                                           andErrorCompletion: errorCompletion];

    [self putBufferObjectIntoTheQueue: obj];
}

- (BufferObject *)createBufferObjectWithOperation: (id<UADSWebViewInvokerOperation>)operation
                                   withCompletion: (UADSWebViewInvokerCompletion)completion
                               andErrorCompletion: (UADSWebViewInvokerErrorCompletion)errorCompletion {
    BufferObject *obj = [BufferObject new];

    obj.operation = operation;
    obj.completion = completion;
    obj.errorCompletion = errorCompletion;
    return obj;
}

- (void)putBufferObjectIntoTheQueue: (BufferObject *)obj {
    dispatch_sync(_serialQueue, ^{
        [self.buffer addObject: obj];
    });
}

- (void)sdkDidInitialize {
    dispatch_sync(_serialQueue, ^{
        [self invokeBufferedObjects];
        [self clearBuffer];
    });
}

- (void)invokeBufferedObjects {
    [_buffer enumerateObjectsUsingBlock: ^(BufferObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self callInvokerUsingBufferObject: obj];
    }];
}

- (void)callInvokerUsingBufferObject: (BufferObject *)obj {
    [self callInvokerWithOperation: obj.operation
                    withCompletion: obj.completion
                andErrorCompletion: obj.errorCompletion];
}

- (void)clearBuffer {
    [self.buffer removeAllObjects];
}

- (void)sdkInitializeFailed: (NSError *)error {
    dispatch_sync(_serialQueue, ^{
        [self failBufferedObjectsWithError: error];
        [self clearBuffer];
    });
}

- (void)failBufferedObjectsWithError: (NSError *)error {
    [_buffer enumerateObjectsUsingBlock: ^(BufferObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self   failWithError: error
            usingBufferObject: obj];
    }];
}

- (void)failWithError: (NSError *)error
    usingBufferObject: (BufferObject *)obj {
    UADSInternalError *internalError = [UADSInternalError newWithErrorCode: kUADSInternalErrorWebView
                                                                 andReason: kUADSInternalErrorWebViewSDKNotInitialized
                                                                andMessage: error.localizedDescription];

    obj.errorCompletion(internalError);
}

- (UADSInternalError *)notInitializedError {
    return [UADSInternalError newWithErrorCode: -1
                                     andReason: NOT_INITIALIZED
                                    andMessage: kSDKNotInitializedErrorMessage];
}

@end
