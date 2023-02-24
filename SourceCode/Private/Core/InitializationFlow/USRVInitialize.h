#import "USRVConfiguration.h"
#import "USRVConnectivityMonitor.h"
#import "USRVApiSdk.h"
#import <Foundation/Foundation.h>
#import "USRVInitializeStateType.h"



@interface USRVInitialize : NSObject

+ (void)initialize: (USRVConfiguration *)configuration;
+ (void)                           reset;
+ (USRVDownloadLatestWebViewStatus)downloadLatestWebView;

@end

// BASE STATE

@interface USRVInitializeState : NSOperation<USRVInitializeTask>

@property (nonatomic, strong) USRVConfiguration *configuration;

- (instancetype)                   execute;
- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration;
- (NSString *)metricName;

@end
