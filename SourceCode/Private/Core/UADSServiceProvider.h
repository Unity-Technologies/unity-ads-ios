#import <Foundation/Foundation.h>
#import "UADSConfigurationCRUDBase.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "USRVSDKMetrics.h"
#import "UADSLogger.h"
#import "UADSConfigurationLoader.h"
#import "UADSConfigurationLoaderBuilder.h"
#import "UADSPerformanceLogger.h"
#import "UADSInitializeEventsMetricSender.h"
#import "UADSPerformanceMeasurer.h"
#import "UADSWebViewEventSender.h"
#import "UADSServiceProviderProxy.h"
#import "USRVInitializeStateFactory.h"
#import "UADSDeviceInfoProvider.h"
NS_ASSUME_NONNULL_BEGIN


@interface UADSServiceProvider : NSObject<UADSConfigurationLoaderProvider>
@property (nonatomic, strong) UADSServiceProviderProxy* objBridge;
@property (nonatomic, strong) id<UADSConfigurationCRUD> configurationStorage;
@property (nonatomic, strong) id<ISDKMetrics, ISDKPerformanceMetricsSender>metricSender;
@property (nonatomic, strong) id<IUSRVWebRequestFactory>metricsRequestFactory;
@property (nonatomic, strong) id<IUSRVWebRequestFactory>webViewRequestFactory;
@property (nonatomic, strong) id<UADSLogger>logger;
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> hbTokenReader;
@property (nonatomic, strong) id<UADSWebViewEventSender> webViewEventSender;
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderBuilder *tokenBuilder;
@property (nonatomic, strong) id<UADSPrivacyResponseSaver, UADSPrivacyResponseReader, UADSPrivacyResponseSubject> privacyStorage;
@property (nonatomic, strong) id<UADSRetryInfoReader> retryReader;
@property (nonatomic, strong) USRVInitializeStateFactory* stateFactory;
- (id<UADSHeaderBiddingAsyncTokenReader>)nativeTokenGenerator;
- (id<UADSConfigurationSaver>) configurationSaver;
- (id<UADSPerformanceLogger>)  performanceLogger;
- (UADSPerformanceMeasurer *)  performanceMeasurer;
- (UADSSDKInitializerProxy *)sdkInitializer;
- (USRVInitializeStateFactory *)stateFactory;

- (BOOL)newInitFlowEnabled;
- (NSString *)sharedSessionId;
@end

NS_ASSUME_NONNULL_END
