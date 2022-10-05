#import "UADSProxyReflection.h"
#import "UADSCommonNetworkResponseProxy.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSNetworkSuccessCompletion)(NSDictionary *_Nonnull);
typedef void (^UADSNetworkErrorCompletion)(NSDictionary *_Nonnull);

typedef void (^UADSDownloadSuccessCompletion)(NSURL *_Nonnull);

@interface UADSCommonNetworkProxy : UADSProxyReflection
- (void)sendRequestUsing: (NSDictionary *)dictionary
       successCompletion: (UADSNetworkSuccessCompletion)success
      andErrorCompletion: (UADSNetworkErrorCompletion)errorCompletion;

- (void)downloadWebView: (UADSDownloadSuccessCompletion)success
               andError: (UADSNetworkErrorCompletion)errorCompletion;
@end

NS_ASSUME_NONNULL_END
