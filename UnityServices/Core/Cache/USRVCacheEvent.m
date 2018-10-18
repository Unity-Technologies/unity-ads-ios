#import "USRVCacheEvent.h"

static NSString *downloadStarted = @"DOWNLOAD_STARTED";
static NSString *downloadStopped = @"DOWNLOAD_STOPPED";
static NSString *downloadEnd = @"DOWNLOAD_END";
static NSString *downloadError = @"DOWNLOAD_ERROR";
static NSString *progress = @"DOWNLOAD_PROGRESS";

NSString *NSStringFromCacheEvent(UnityServicesCacheEvent event) {
    switch (event) {
        case kUnityServicesDownloadStarted:
            return downloadStarted;
        case kUnityServicesDownloadStopped:
            return downloadStopped;
        case kUnityServicesDownloadEnd:
            return downloadEnd;
        case kUnityServicesDownloadProgress:
            return progress;
        case kUnityServicesDownloadError:
            return downloadError;
    }
}
