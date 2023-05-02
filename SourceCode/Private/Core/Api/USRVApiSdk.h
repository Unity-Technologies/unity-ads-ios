#import "USRVWebViewCallback.h"
@interface USRVApiSdk : NSObject

typedef NS_ENUM (NSInteger, USRVDownloadLatestWebViewStatus) {
    kDownloadLatestWebViewStatusInitQueueNull,
    kDownloadLatestWebViewStatusInitQueueNotEmpty,
    kDownloadLatestWebViewStatusMissingLatestConfig,
    kDownloadLatestWebViewStatusBackgroundDownloadStarted
};
+ (void)WebViewExposed_getTrrData: (nonnull USRVWebViewCallback *)callback;
@end
