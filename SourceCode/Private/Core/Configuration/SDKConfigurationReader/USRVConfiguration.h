#import "USRVInitializationRequestFactory.h"
#import "UADSConfigurationExperiments.h"
#import "UADSConfigurationLoader.h"
#import "USRVWebRequest.h"

extern NSString *const kUnityServicesConfigValueMetricsUrl;
extern NSString *const kUnityServicesConfigValueMetricSamplingRate;
extern NSString *const kUnityServicesConfigValueHash;
extern NSString *const kUnityServicesConfigValueUrl;
extern NSString *const kUnityServicesConfigValueVersion;
extern NSString *const kUnityServicesConfigValueSdkVersion;
extern NSString *const kUnityServicesConfigValueNetworkErrorTimeout;
extern NSString *const kUnityServicesConfigValueDelayWebviewUpdate;
extern NSString *const kUnityServicesConfigValueExperiments;
extern NSString *const kUnityServicesConfigValueExperimentsObject;
extern NSString *const kUnityServicesConfigValueShowTimeout;
extern NSString *const kUnityServicesConfigValueLoadTimeout;
extern NSString *const kUnityServicesConfigValueWebViewTimeout;
extern NSString *const kUnityServicesConfigValueSource;
extern NSString *const kUnityServicesConfigValueUAToken;
extern NSString *const kUnityServicesConfigValueStateID;


@class USRVModuleConfiguration;
@protocol ISDKMetrics;
@class UADSInitializeEventsMetricSender;

@interface USRVConfiguration : NSObject

@property (nonatomic, strong) NSString *webViewUrl;
@property (nonatomic, strong) NSString *webViewHash;
@property (nonatomic, strong) NSString *webViewData;
@property (nonatomic, strong) NSString *webViewVersion;
@property (nonatomic, assign) BOOL delayWebViewUpdate;
@property (nonatomic, assign) int resetWebAppTimeout;
@property (nonatomic, assign) int maxRetries;
@property (nonatomic, assign) long retryDelay;
@property (nonatomic, assign) double retryScalingFactor;
@property (nonatomic, assign) int connectedEventThresholdInMs;
@property (nonatomic, assign) int maximumConnectedEvents;
@property (nonatomic, assign) long networkErrorTimeout;
@property (nonatomic, assign) int showTimeout;
@property (nonatomic, assign) int loadTimeout;
@property (nonatomic, assign) int webViewTimeout;
@property (nonatomic, strong) NSString *metricsUrl;
@property (nonatomic, assign) double metricSamplingRate;
@property (nonatomic, assign) long webViewAppCreateTimeout;
@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *configUrl;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSError *requestError;
@property (nonatomic, strong) NSString *headerBiddingToken;
@property (nonatomic, strong) NSString *stateId;
@property (nonatomic, strong) UADSConfigurationExperiments *experiments;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, assign) long hbTokenTimeout;
@property (nonatomic, assign) long privacyWaitTimeout;
@property (nonatomic, assign) BOOL enableNativeMetrics;
@property (nonatomic, strong, readonly) NSDictionary *originalJSON;
- (void)        saveToDisk;
- (instancetype)initWithConfigUrl: (NSString *)url;
- (instancetype)initWithConfigJsonData: (NSData *)configJsonData;
- (void)                     makeRequest;
- (void)handleConfigurationData: (NSData *)configData;
+ (instancetype)newFromJSON: (NSDictionary *)json;
- (NSArray<NSString *> *)    getWebAppApiClassList;
- (NSArray<NSString *> *)    getModuleConfigurationList;
- (USRVModuleConfiguration *)getModuleConfiguration: (NSString *)moduleName;
- (NSData *)                 toJson;
- (BOOL)                     hasValidWebViewURL;

- (void)setRequestFactory: (id<IUSRVWebRequestFactory>)requestFactory;
@end
