#import "USRVInitialize.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateDownloadLatestWebView : USRVInitializeState

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) long retryDelay;

@end

NS_ASSUME_NONNULL_END
