#import "UnityAds.h"
#import "UADSCacheOperation.h"
#import "UADSWebViewApp.h"
#import "UADSCacheEvent.h"
#import "UADSWebViewEventCategory.h"
#import "UADSApiRequest.h"
#import "UADSApiCache.h"
#import "UADSConnectivityUtils.h"

@implementation UADSCacheOperation

- (instancetype)initWithSource:(NSString *)source target:(NSString *)target connectTimeout:(int)connectTimeout headers:(NSDictionary<NSString*, NSArray*> *)headers {
    self = [super init];

    if (self) {
        [self setSource:source];
        [self setTarget:target];
        [self setConnectTimeout:connectTimeout];
        [self setProgressEventInterval:0];
        [self setLastProgressEvent:0];
        [self setExpectedContentSize:0];
        [self setHeaders:headers];
    }

    return self;
}

- (void)main {
    UADSLogDebug(@"Unity Ads cache: Cache operation started for file %@", self.target);
    __weak UADSCacheOperation *weakSelf = self;

    NSURL *candidateUrl = [NSURL URLWithString:self.source];
    if (!candidateUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:NSStringFromCacheError(kUnityAdsMalformedUrl),
                self.source,
             nil];
        });

        return;
    }

    [self startObserving];

    NSFileHandle *fileHandle = nil;
    unsigned long long fileSize = 0;
    __block NSDictionary<NSString*,NSString*> *responseHeaders = NULL;
    __block long responseCode = 0;
    
    NSMutableDictionary<NSString*,NSArray*> *headers = [[NSMutableDictionary alloc] init];
    if (self.headers) {
        [headers addEntriesFromDictionary:self.headers];
    }

    long long startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.request = [[UADSWebRequest alloc] initWithUrl:self.source requestType:@"GET" headers:NULL connectTimeout:self.connectTimeout];

    if ([[NSFileManager defaultManager] fileExistsAtPath:self.target]) {
        @try {
            fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.target];
            fileSize = [fileHandle seekToEndOfFile];
            UADSLogDebug(@"Unity Ads cache: resuming download from %@ to %@ at %llu bytes", self.source, self.target, fileSize);
            [headers setValue:[NSArray arrayWithObject:[NSString stringWithFormat:@"bytes=%llu-", fileSize]] forKey:@"Range"];
        } @catch (NSException *exception) {
            [fileHandle closeFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                    category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                    param1:NSStringFromCacheError(kUnityAdsFileIOError),
                    weakSelf.source,
                    [NSNumber numberWithLongLong:fileSize],
                    [NSNumber numberWithLongLong:weakSelf.expectedContentSize],
                    exception.name,
                    exception.reason,
                 nil];
            });
            [self stopObserving];
            return;
        }
    } else {
        @try {
            UADSLogDebug(@"Unity Ads cache: starting download from %@ to %@", self.source, self.target);
            [[NSFileManager defaultManager] createFileAtPath:self.target contents:nil attributes:nil];
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.target];
        } @catch (NSException *exception) {
            [fileHandle closeFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                    category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                    param1:NSStringFromCacheError(kUnityAdsFileIOError),
                    weakSelf.source,
                    [NSNumber numberWithLongLong:fileSize],
                    [NSNumber numberWithLongLong:weakSelf.expectedContentSize],
                    exception.name,
                    exception.reason,
                 nil];
            });
            [self stopObserving];
            return;
        }
    }

    [self.request setProgressBlock:^(NSString *url, long long bytes, long long totalBytes) {
        long long currentTime = ([[NSDate date] timeIntervalSince1970] * 1000);
        if (![weakSelf isCancelled] && weakSelf.progressEventInterval > 0 && weakSelf.lastProgressEvent + weakSelf.progressEventInterval <= currentTime) {
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadProgress)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:weakSelf.source,
                [NSNumber numberWithLongLong:bytes],
                [NSNumber numberWithLongLong:weakSelf.expectedContentSize],
             nil];

            weakSelf.lastProgressEvent = ([[NSDate date] timeIntervalSince1970] * 1000);
        }
    }];
    [self.request setStartBlock:^(NSString *url, long long totalBytes) {
        [weakSelf setExpectedContentSize:(totalBytes + fileSize)];
        responseHeaders = [weakSelf.request responseHeaders];
        responseCode = [weakSelf.request responseCode];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadStarted)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:weakSelf.source,
                [NSNumber numberWithLongLong:fileSize],
                [NSNumber numberWithLongLong:weakSelf.expectedContentSize],
                [NSNumber numberWithLong:responseCode],
                [UADSApiRequest getHeadersArray:responseHeaders],
             nil];
        });
    }];

    if ([UADSConnectivityUtils getNetworkStatus] == NotReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:NSStringFromCacheError(kUnityAdsNoInternet),
                weakSelf.source,
             nil];
        });
        [self stopObserving];
        return;
    }

    [self.request setHeaders:headers];
    NSData *fileData = [self.request makeRequest];
    if (self.request.error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:NSStringFromCacheError(kUnityAdsNetworkError),
                self.source,
                [NSNumber numberWithLongLong:fileSize],
                [NSNumber numberWithLongLong:self.expectedContentSize],
             nil];
        });

        @try {
            [fileHandle writeData:fileData];
            [fileHandle synchronizeFile];
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                    category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                    param1:NSStringFromCacheError(kUnityAdsFileIOError),
                    self.source,
                    [NSNumber numberWithLongLong:fileSize],
                 nil];
            });
        } @finally {
            [fileHandle closeFile];
            fileHandle = nil;
        }

        [self stopObserving];
        return;
    }

    @try {
        [fileHandle writeData:fileData];
        [fileHandle synchronizeFile];
    } @catch (NSException *exception) {
        UADSLogError(@"Unity Ads cache: couldn't write file. Error name: %@ reason: %@", exception.name, exception.reason);
        [fileHandle closeFile];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:NSStringFromCacheError(kUnityAdsFileIOError),
                self.source,
                [NSNumber numberWithLongLong:fileSize],
             nil];
        });

        [self stopObserving];
        return;
    } @finally {
        [fileHandle closeFile];
        fileHandle = nil;
    }

    long long dataLength = [fileData length];
    long long duration = ([[NSDate date] timeIntervalSince1970] * 1000) - startTime;

    if (![self isCancelled]) {
        UADSLogDebug(@"Unity Ads cache: file %@ of %llu bytes downloaded in %lldms", self.target, dataLength, duration);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadEnd)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:self.source,
                [NSNumber numberWithLongLong:dataLength],
                [NSNumber numberWithLongLong:self.expectedContentSize],
                [NSNumber numberWithLongLong:duration],
                [NSNumber numberWithLong:responseCode],
                [UADSApiRequest getHeadersArray:responseHeaders],
             nil];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadStopped)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:self.source,
                [NSNumber numberWithLongLong:dataLength],
                [NSNumber numberWithLongLong:self.expectedContentSize],
                [NSNumber numberWithLongLong:duration],
                [NSNumber numberWithLong:responseCode],
                [UADSApiRequest getHeadersArray:responseHeaders],
             nil];
        });
    }
    
    [self stopObserving];
    UADSLogDebug(@"Unity Ads cache: Cache operation finished for file %@", self.target);
}

- (void)startObserving {
    @try {
        [self addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:nil];
    }
    @catch (id exception) {
    }
}

- (void)stopObserving {
    @try {
        [self removeObserver:self forKeyPath:@"isCancelled"];
    }
    @catch (id exception) {
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isCancelled"]) {
        if (self.request && !self.request.finished) {
            [self.request cancel];
        }
    }
}

@end
