#import "UnityAds.h"
#import "UADSCacheOperation.h"
#import "UADSWebViewApp.h"
#import "UADSCacheEvent.h"
#import "UADSWebViewEventCategory.h"
#import "UADSApiRequest.h"

@implementation UADSCacheOperation

- (instancetype)initWithSource:(NSString *)source target:(NSString *)target connectTimeout:(int)connectTimeout {
    self = [super init];

    if (self) {
        [self setSource:source];
        [self setTarget:target];
        [self setConnectTimeout:connectTimeout];
        [self setProgressEventInterval:0];
        [self setLastProgressEvent:0];
        [self setExpectedContentSize:0];
    }

    return self;
}

- (void)main {
    [self startObserving];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.target]) {
        if (![[NSFileManager defaultManager] createFileAtPath:self.target contents:nil attributes:nil]) {
            UADSLogError(@"Unity Ads cache: couldn't create target file %@", self.target);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                                                 category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                                                   param1:self.target, [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], nil];
            });
            [self stopObserving];
            return;
        };
    }

    NSFileHandle *fileHandle = nil;
    unsigned long long fileSize = 0;
    __weak UADSCacheOperation *weakSelf = self;
    __block NSDictionary<NSString*,NSString*> *responseHeaders = NULL;
    __block long responseCode = 0;
    
    long startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.request = [[UADSWebRequest alloc] initWithUrl:self.source requestType:@"GET" headers:NULL connectTimeout:self.connectTimeout];

    if ([[NSFileManager defaultManager] fileExistsAtPath:self.target]) {
        @try {
            fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.target];
            fileSize = [fileHandle seekToEndOfFile];
            NSDictionary<NSString*,NSArray*> *headers = @{@"Range": [NSArray arrayWithObject:[NSString stringWithFormat:@"bytes=%llu-", fileSize]]};
            [self.request setHeaders:headers];
            
            UADSLogDebug(@"Unity Ads cache: resuming download from %@ to %@ at %llu bytes", self.source, self.target, fileSize);
        } @catch (NSException *exception) {
            [fileHandle closeFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                                                 category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                                                   param1:self.target, [NSNumber numberWithLongLong:fileSize], [NSNumber numberWithLongLong:self.expectedContentSize], exception.name, exception.reason, nil];
            });
            [self stopObserving];
            return;
        }
    } else {
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.target];
        UADSLogDebug(@"Unity Ads cache: starting download from %@ to %@", self.source, self.target);
    }

    [self.request setProgressBlock:^(NSString *url, long long bytes, long long totalBytes) {
        long currentTime = ([[NSDate date] timeIntervalSince1970] * 1000);
        if (![weakSelf isCancelled] && self.progressEventInterval > 0 && self.lastProgressEvent + self.progressEventInterval <= currentTime) {
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadProgress)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                                               param1:weakSelf.source, [NSNumber numberWithLongLong:bytes], [NSNumber numberWithLongLong:weakSelf.expectedContentSize], nil];
            weakSelf.lastProgressEvent = ([[NSDate date] timeIntervalSince1970] * 1000);
        }
    }];
    [self.request setStartBlock:^(NSString *url, long long totalBytes) {
        [weakSelf setExpectedContentSize:totalBytes];
        responseHeaders = [weakSelf.request responseHeaders];
        responseCode = [weakSelf.request responseCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadStarted)
                                             category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                                               param1:weakSelf.source, [NSNumber numberWithLongLong:fileSize], [NSNumber numberWithLongLong:weakSelf.expectedContentSize], [NSNumber numberWithLong:responseCode], [UADSApiRequest getHeadersArray:responseHeaders], nil];
        });
    }];

    NSData *fileData = [self.request makeRequest];
    if (self.request.error) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadError)
                                         category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                                           param1:self.target, [NSNumber numberWithLongLong:fileSize], [NSNumber numberWithLongLong:self.expectedContentSize], nil];
        [fileHandle closeFile];
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath:self.target error:&deleteError];
        if (deleteError) {
            UADSLogError(@"Unity Ads cache: error occured while removing file: %@",[deleteError userInfo]);
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
                                               param1:self.target, [NSNumber numberWithLongLong:fileSize], nil];
        });

        [self stopObserving];
        return;
    } @finally {
        [fileHandle closeFile];
        fileHandle = nil;
    }

    long long dataLength = [fileData length];
    long duration = ([[NSDate date] timeIntervalSince1970] * 1000) - startTime;

    if (![self isCancelled]) {
        UADSLogDebug(@"Unity Ads cache: file %@ of %llu bytes downloaded in %lums", self.target, dataLength, duration);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromCacheEvent(kUnityAdsDownloadEnd)
                category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryCache)
                param1:self.source,
                [NSNumber numberWithLongLong:dataLength],
                [NSNumber numberWithLongLong:self.expectedContentSize],
                [NSNumber numberWithLong:duration],
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
                [NSNumber numberWithLong:(long) dataLength],
                [NSNumber numberWithLongLong:(long) self.expectedContentSize],
                [NSNumber numberWithLong:duration],
                [NSNumber numberWithLong:responseCode],
                [UADSApiRequest getHeadersArray:responseHeaders],
             nil];
        });
    }
    
    [self stopObserving];
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