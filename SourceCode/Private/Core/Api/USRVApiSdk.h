#import "USRVWebViewCallback.h"
@interface USRVApiSdk : NSObject

typedef NS_ENUM (NSInteger, USRVDownloadLatestWebViewStatus) {
    kDownloadLatestWebViewStatusInitQueueNull,
    kDownloadLatestWebViewStatusInitQueueNotEmpty,
    kDownloadLatestWebViewStatusMissingLatestConfig,
    kDownloadLatestWebViewStatusBackgroundDownloadStarted
};
+ (void)setServiceProviderForTesting: (id)sProvider;
+ (void)WebViewExposed_getTrrData: (USRVWebViewCallback *)callback;
@end
