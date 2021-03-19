#import "USRVWebViewAsyncOperation.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewAsyncOperationStorage.h"

static NSString * const CALLBACK_METHOD_NAME = @"callback:";

@interface USRVWebViewAsyncOperation()
@property (nonatomic, strong) NSString *webViewMethod;
@property (nonatomic, strong) NSString *webViewClass;
@property (nonatomic, strong) NSArray *parameters;
@property (nonatomic, assign) int waitTime;
@property (nonatomic, assign) BOOL success;
@property (nonatomic) USRVWebViewAsyncOperationStatus status;
@property (nonatomic, strong) NSCondition *lock;
@end

@implementation USRVWebViewAsyncOperation

+ (instancetype)newWithMethod:(NSString *)webViewMethod
                 webViewClass:(NSString *)webViewClass
                   parameters:(NSArray *)parameters
                     waitTime:(int)waitTime {
    
    USRVWebViewAsyncOperation *obj = [USRVWebViewAsyncOperation new];

    obj.webViewMethod = webViewMethod;
    obj.webViewClass = webViewClass;
    obj.parameters = parameters;
    obj.waitTime = waitTime;
    obj.success = false;
    obj.status = kUSRVWebViewAsyncOperationStatusIdle;
    
    return obj;
}



- (void)main {
    self.status = kUSRVWebViewAsyncOperationStatusWaiting;
    self.lock = [[NSCondition alloc] init];
    [self sendWebViewInvocation];
    [self.lock lock];
    
    if (self.waitTime > 0) {
        self.success = [self.lock waitUntilDate: [[NSDate alloc] initWithTimeIntervalSinceNow:self.waitTime]];
        [self.lock unlock];
        self.lock = nil;
        if (!self.success) {
            self.status = kUSRVWebViewAsyncOperationStatusTimeout;
            USRVLogError(@"Unity Ads callback timed out! %@ %@", self.className, self.webViewMethod);
        }
    }
}


-(NSString *)className {
    return NSStringFromClass(self.class);
}

- (void)sendWebViewInvocation {

    [[USRVWebViewApp getCurrentApp] invokeMethod: self.webViewMethod
                                       className: self.webViewClass
                                   receiverClass: self.className
                                        callback: CALLBACK_METHOD_NAME
                                          params: self.parameters];
}


+(void)setStatus:(USRVWebViewAsyncOperationStatus)status {
    self.storage.status = status;
}

+(USRVWebViewAsyncOperationStatus)status {
    return self.storage.status;
}

+(void)setStatusCode:(NSString *)status {
    self.storage.statusCode = status;
}

+(NSString *)statusCode {
    return self.storage.statusCode;
}

+(USRVWebViewAsyncOperationStorage *)storage {
    return USRVWebViewAsyncOperationStorage.sharedInstance;
}

+ (void)setLock:(NSCondition *)lock {
    self.storage.lock = lock;
}

+ (NSCondition *)lock {
    return  self.storage.lock;
}

- (void)execute:(USRVWebViewAsyncOperationCompletion)completion {
    dispatch_async(self.operationQueue, ^{
        [self main];
        completion(self.status, self.statusCode);
    });
}

-(dispatch_queue_t)operationQueue {
    return self.storage.operationQueue;
}

-(void)setStatus:(USRVWebViewAsyncOperationStatus)status {
    self.storage.status = status;
}

-(USRVWebViewAsyncOperationStatus)status {
    return self.storage.status;
}

-(void)setStatusCode:(NSString *)status {
    self.storage.statusCode = status;
}

-(NSString *)statusCode {
    return self.storage.statusCode;
}

-(USRVWebViewAsyncOperationStorage *)storage {
    return USRVWebViewAsyncOperationStorage.sharedInstance;
}

- (void)setLock:(NSCondition *)lock {
    self.storage.lock = lock;
}

- (NSCondition *)lock {
    return self.storage.lock;
}


+ (void)callback:(NSArray *)params {
    if (self.lock) {
        [self processResponse: params];
        [self.self signalLock];
    }
}

+(void)processResponse: (NSArray *)params {
    if ([[params firstObject] isEqualToString:@"OK"]) {
        self.status = kUSRVWebViewAsyncOperationStatusOK;
    } else {
        self.status = kUSRVWebViewAsyncOperationStatusError;
        self.statusCode = [params firstObject];
        
    }
}

+(void)signalLock {
    [self.lock lock];
    [self.lock signal];
    [self.lock unlock];
}

@end
