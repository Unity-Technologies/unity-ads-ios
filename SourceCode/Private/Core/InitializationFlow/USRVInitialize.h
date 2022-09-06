#import "USRVConfiguration.h"
#import "USRVConnectivityMonitor.h"
#import "USRVApiSdk.h"
#import <Foundation/Foundation.h>

@interface USRVInitialize : NSObject

+ (void)initialize: (USRVConfiguration *)configuration;
+ (void)                           reset;
+ (USRVDownloadLatestWebViewStatus)downloadLatestWebView;

@end

// BASE STATE

@interface USRVInitializeState : NSOperation

@property (nonatomic, strong) USRVConfiguration *configuration;

- (instancetype)                   execute;
- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration;

@end
