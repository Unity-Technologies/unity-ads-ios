#import "UADSCacheQueue.h"
#import "UADSWebRequest.h"
#import "UADSCacheOperation.h"

@implementation UADSCacheQueue

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

+ (BOOL)download:(NSString *)source target:(NSString *)target {
    return [UADSCacheQueue downloadFile:source target:target];
}

+ (BOOL)downloadFile:(NSString *)source target:(NSString *)target {
    if (source && target && cacheQueue.operationCount == 0) {
        UADSCacheOperation *cacheOperation = [[UADSCacheOperation alloc] initWithSource:source target:target connectTimeout:connectTimeout];
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