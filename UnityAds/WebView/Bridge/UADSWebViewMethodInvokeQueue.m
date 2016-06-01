#import "UADSWebViewMethodInvokeQueue.h"

@implementation UADSWebViewMethodInvokeQueue

static dispatch_once_t onceToken;
static NSOperationQueue *methodInvokeQueue;

+ (void)addOperation:(UADSWebViewMethodInvokeOperation *)operation {
    dispatch_once(&onceToken, ^{
        if (!methodInvokeQueue) {
            methodInvokeQueue = [[NSOperationQueue alloc] init];
            methodInvokeQueue.maxConcurrentOperationCount = 1;
        }
    });
    
    [methodInvokeQueue addOperation:operation];
}

@end