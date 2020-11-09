@class USRVModuleConfiguration;

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
@property (nonatomic, assign) int noFillTimeout;
@property (nonatomic, strong) NSString *metricsUrl;
@property (nonatomic, assign) double metricSamplingRate;
@property (nonatomic, assign) long webViewAppCreateTimeout;
@property (nonatomic, strong) NSString *sdkVersion;

@property (nonatomic, strong) NSString *configUrl;
@property (nonatomic, strong) NSString *error;

- (instancetype)initWithConfigUrl:(NSString *)url;
- (instancetype)initWithConfigJsonData:(NSData *)configJsonData;
- (void)makeRequest;
- (void)handleConfigurationData:(NSData *)configData;
- (NSArray<NSString*>*)getWebAppApiClassList;
- (NSArray<NSString*>*)getModuleConfigurationList;
- (USRVModuleConfiguration *)getModuleConfiguration:(NSString *)moduleName;
- (NSData*)toJson;

@end
