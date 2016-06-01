#import "UADSCacheEvent.h"

static NSString *downloadStarted = @"DOWNLOAD_STARTED";
static NSString *downloadStopped = @"DOWNLOAD_STOPPED";
static NSString *downloadEnd = @"DOWNLOAD_END";
static NSString *downloadError = @"DOWNLOAD_ERROR";
static NSString *progress = @"DOWNLOAD_PROGRESS";

NSString *NSStringFromCacheEvent(UnityAdsCacheEvent event) {
    switch (event) {
        case kUnityAdsDownloadStarted:
            return downloadStarted;
        case kUnityAdsDownloadStopped:
            return downloadStopped;
        case kUnityAdsDownloadEnd:
            return downloadEnd;
        case kUnityAdsDownloadProgress:
            return progress;
        case kUnityAdsDownloadError:
            return downloadError;
    }
}
