#import "USRVWebViewAsyncOperationStorage.h"

@implementation USRVWebViewAsyncOperationStorage {
    USRVWebViewAsyncOperationStatus internalStatus;
    NSCondition *internalLock;
}

+ (instancetype)sharedInstance {
    static USRVWebViewAsyncOperationStorage *storage = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        storage = [self new];
    });
    return storage;
}

- (instancetype)init {
    SUPER_INIT;
    self.operationQueue = dispatch_queue_create("com.unityAds.async.operation.queue", DISPATCH_QUEUE_SERIAL);
    self.syncQueue = dispatch_queue_create("com.unityAds.async.sync.queue", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (USRVWebViewAsyncOperationStatus)status {
    __block USRVWebViewAsyncOperationStatus returnedStatus;

    dispatch_sync(_syncQueue, ^{
        returnedStatus = internalStatus;
    });
    return returnedStatus;
}

- (void)setStatus: (USRVWebViewAsyncOperationStatus)status {
    dispatch_sync(_syncQueue, ^{
        internalStatus = status;
    });
}

- (NSCondition *)lock {
    __block NSCondition *returnedLock;

    dispatch_sync(_syncQueue, ^{
        returnedLock = internalLock;
    });
    return returnedLock;
}

- (void)setLock: (NSCondition *)lock {
    dispatch_sync(_syncQueue, ^{
        internalLock = lock;
    });
}


- (void)resetForTesting {
    dispatch_sync(_syncQueue, ^{
        internalLock = nil;
        internalStatus = kUSRVWebViewAsyncOperationStatusIdle;
        
    });
}
@end
