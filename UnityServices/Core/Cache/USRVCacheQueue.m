#import "USRVCacheQueue.h"
#import "USRVWebRequest.h"
#import "USRVCacheOperation.h"

@implementation USRVCacheQueue

static NSOperationQueue *cacheQueue;

static int connectTimeout = 30000;
static int progressInterval = 0;
static dispatch_once_t onceToken;

+ (void)start {
    dispatch_once(&onceToken, ^{
        if (!cacheQueue) {
            cacheQueue = [[NSOperationQueue alloc] init];
            cacheQueue.maxConcurrentOperationCount = 1;
        }
    });
}

+ (BOOL)download:(NSString *)source target:(NSString *)target headers:(NSDictionary<NSString*, NSArray*> *)headers append:(BOOL)append {
    return [USRVCacheQueue downloadFile:source target:target headers:headers append:append];
}

+ (BOOL)downloadFile:(NSString *)source target:(NSString *)target headers:(NSDictionary<NSString*, NSArray*> *)headers append:(BOOL)append {
    if (source && target) {
        USRVCacheOperation *cacheOperation = [[USRVCacheOperation alloc] initWithSource:source target:target connectTimeout:connectTimeout headers:headers append:append];
        if (progressInterval > 0) {
            [cacheOperation setProgressEventInterval:progressInterval];
        }

        [cacheQueue addOperation:cacheOperation];
        return true;
    }

    return false;
}

+ (BOOL)hasOperations {
    return cacheQueue.operationCount > 0;
}

+ (void)cancelAllDownloads {
    if (cacheQueue) {
        [cacheQueue cancelAllOperations];
    }
}

+ (void)setProgressInterval:(int)interval {
    progressInterval = interval;
}

+ (int)getProgressInterval {
    return progressInterval;
}

+ (void)setConnectTimeout:(int)timeout {
    connectTimeout = timeout;
}

+ (int)getConnectTimeout {
    return connectTimeout;
}
@end
