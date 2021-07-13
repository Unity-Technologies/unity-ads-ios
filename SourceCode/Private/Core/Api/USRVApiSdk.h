@interface USRVApiSdk : NSObject

typedef NS_ENUM (NSInteger, USRVDownloadLatestWebViewStatus) {
    kDownloadLatestWebViewStatusInitQueueNull,
    kDownloadLatestWebViewStatusInitQueueNotEmpty,
    kDownloadLatestWebViewStatusMissingLatestConfig,
    kDownloadLatestWebViewStatusBackgroundDownloadStarted
};

@end
