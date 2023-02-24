#import "USRVConfiguration.h"
#import "USRVSdkProperties.h"
#import "USRVWebRequestFactory.h"
#import "USRVConfigurationStorage.h"
#import "UADSServiceProviderProxy.h"
#import "UADSTools.h"
#import "UADSTokenStorage.h"
#import "NSDictionary+Merge.h"
#import "NSMutableDictionary+SafeOperations.h"

NSString *const kUnityServicesConfigValueHash = @"hash";
NSString *const kUnityServicesConfigValueUrl = @"url";
NSString *const kUnityServicesConfigValueVersion = @"version";
NSString *const kUnityServicesConfigValueDelayWebviewUpdate = @"dwu";
NSString *const kUnityServicesConfigValueResetWebAppTimeout = @"rwt";
NSString *const kUnityServicesConfigValueMaxRetries = @"mr";
NSString *const kUnityServicesConfigValueRetryDelay = @"rd";
NSString *const kUnityServicesConfigValueRetryScalingFactor = @"rcf";
NSString *const kUnityServicesConfigValueConnectedEventThreshold = @"cet";
NSString *const kUnityServicesConfigValueMaximumConnectedEvents = @"mce";
NSString *const kUnityServicesConfigValueNetworkErrorTimeout = @"net";
NSString *const kUnityServicesConfigValueMetricsUrl = @"murl";
NSString *const kUnityServicesConfigValueMetricSamplingRate = @"msr";
NSString *const kUnityServicesConfigValueShowTimeout = @"sto";
NSString *const kUnityServicesConfigValueLoadTimeout = @"lto";
NSString *const kUnityServicesConfigValueWebViewTimeout = @"wto";
NSString *const kUnityServicesConfigValueWebViewAppCreateTimeout = @"wct";
NSString *const kUnityServicesConfigValueSdkVersion = @"sdkv";

NSString *const kUnityServicesConfigValueFastFlowFlag = @"ffl";
NSString *const kUnityServicesConfigValueUAToken = @"tkn";
NSString *const kUnityServicesConfigValueStateID = @"sid";
NSString *const kUnityServicesConfigValueExperiments = @"exp";
NSString *const kUnityServicesConfigValueExperimentsObject = @"expo";
NSString *const kUnityServicesConfigValueSource = @"src";
NSString *const kUnityServicesConfigHeaderBiddingTimeout = @"tto";
NSString *const kUnityServicesConfigPrivacyWaitTimeout = @"prwto";
NSString *const kUnityServicesConfigSessionToken = @"sTkn";

NSString *const kUnityServicesConfigValueScarHbUrl = @"scurl";

@interface USRVConfiguration ()
@property (nonatomic, strong) NSDictionary *originalJSON;
@property (nonatomic, strong) id<IUSRVWebRequestFactory> requestFactory;
@end

@implementation USRVConfiguration

+ (instancetype)newFromJSON: (NSDictionary *)json {
    USRVConfiguration *config = [self new];

    config.originalJSON = json;
    [config setOptionalFields: json];
    return config;
}

- (instancetype)initWithConfigUrl: (NSString *)url {
    self = [self init];
    self.configUrl = url;
    return self;
}

- (instancetype)initWithConfigJsonData: (NSData *)configJsonData {
    if (configJsonData == nil) {
        return nil;
    }

    self = [super init];

    if (self) {
        [self handleConfigurationData: configJsonData];
    }

    return self;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self setOptionalFields: [[NSDictionary alloc] init]];
        self.requestFactory = [USRVWebRequestFactory new];
    }

    return self;
}

- (NSString *)buildQueryString {
    long long ts = [[NSDate date] timeIntervalSince1970] * 1000;

    return [NSString stringWithFormat: @"&ts=%lld&sdkVersion=%d&sdkVersionName=%@", ts, [USRVSdkProperties getVersionCode], [USRVSdkProperties getVersionName]];
}

- (void)makeRequest {
    if (self.configUrl == nil) {
        [self setError: @"ERROR_NIL_CONFIG_URL"];
        USRVLogError(@"Native Configuration request missing URL");
        return;
    }

    NSString *urlString = [NSString stringWithFormat: @"%@%@", [self configUrl], [self buildQueryString]];

    USRVLogDebug(@"Requesting configuration with: %@", urlString);

    [self setError: nil];
    id<USRVWebRequest> request = [self.requestFactory create: urlString
                                                 requestType: @"GET"
                                                     headers: NULL
                                              connectTimeout: 30000];
    NSData *responseData = [request makeRequest];

    if (request.error) {
        [self setError: @"ERROR_REQUESTING_CONFIG"];
        _requestError = request.error;
        USRVLogError(@"Native Configuration request failed");
        return;
    }

    [self handleConfigurationData: responseData];
} /* makeRequest */

- (void)handleConfigurationData: (NSData *)configData {
    NSError *error;
    NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData: configData
                                                                     options: kNilOptions
                                                                       error: &error];

    if (error) {
        [self setError: @"ERROR_PARSING_CONFIG_RESPONSE"];
        USRVLogError(@"Native Configuration parsing failed");
        return;
    }

    USRVLogDebug(@"Fetched Native Configuration: %@", [configDictionary description]);

    NSString *webviewUrl = configDictionary[kUnityServicesConfigValueUrl];

    if (webviewUrl == nil || [webviewUrl isKindOfClass: [NSNull class]] || [webviewUrl isEqualToString: @""]) {
        [self setError: @"ERROR_NIL_REQUIRED_CONFIGURATION_FIELDS"];
        USRVLogError(@"Native Configuration Webview URL Field Missing");
        return;
    }

    self.webViewUrl = webviewUrl;

    [self setOptionalFields: configDictionary];
} /* handleConfigurationData */

- (void)setOptionalFields: (NSDictionary *)configDictionary {
    self.webViewUrl = self.webViewUrl ? : configDictionary[kUnityServicesConfigValueUrl];
    self.webViewHash = configDictionary[kUnityServicesConfigValueHash] ? : nil;
    self.webViewVersion = configDictionary[kUnityServicesConfigValueVersion] ? : nil;
    self.delayWebViewUpdate = [configDictionary[kUnityServicesConfigValueDelayWebviewUpdate] boolValue] ? : NO;
    self.resetWebAppTimeout = [configDictionary[kUnityServicesConfigValueResetWebAppTimeout] intValue] ? : 10000;
    self.maxRetries = [configDictionary[kUnityServicesConfigValueMaxRetries] intValue] ? : 6;
    self.retryDelay = [configDictionary[kUnityServicesConfigValueRetryDelay] longValue] ? : 5000L;
    self.retryScalingFactor = [configDictionary[kUnityServicesConfigValueRetryScalingFactor] doubleValue] ? : 2.0;
    self.connectedEventThresholdInMs = [configDictionary[kUnityServicesConfigValueConnectedEventThreshold] intValue] ? : 10000;
    self.maximumConnectedEvents = [configDictionary[kUnityServicesConfigValueMaximumConnectedEvents] intValue] ? : 500;
    self.networkErrorTimeout = [configDictionary[kUnityServicesConfigValueNetworkErrorTimeout] longValue] ? : 60000L;
    self.metricsUrl = configDictionary[kUnityServicesConfigValueMetricsUrl] ? : nil;
    self.metricSamplingRate = [configDictionary[kUnityServicesConfigValueMetricSamplingRate] doubleValue] ? : 100;
    self.showTimeout = [configDictionary[kUnityServicesConfigValueShowTimeout] intValue] ? : 10000;
    self.loadTimeout = [configDictionary[kUnityServicesConfigValueLoadTimeout] intValue] ? : 30000;
    self.webViewTimeout = [configDictionary[kUnityServicesConfigValueWebViewTimeout] intValue] ? : 5000;
    self.webViewAppCreateTimeout = [configDictionary[kUnityServicesConfigValueWebViewAppCreateTimeout] longValue] ? : 60000L;
    self.sdkVersion = configDictionary[kUnityServicesConfigValueSdkVersion] ? : nil;
    self.headerBiddingToken = configDictionary[kUnityServicesConfigValueUAToken];
    self.stateId = configDictionary[kUnityServicesConfigValueStateID];
    self.source = [configDictionary[kUnityServicesConfigValueSource] isKindOfClass: [NSNull class]] ? nil : configDictionary[kUnityServicesConfigValueSource];
    NSDictionary *experimentsDictionary = configDictionary[kUnityServicesConfigValueExperimentsObject] ? : (configDictionary[kUnityServicesConfigValueExperiments] ? : @{});

    self.hbTokenTimeout = [configDictionary[kUnityServicesConfigHeaderBiddingTimeout] longLongValue] ? : 5000; //tto
    self.privacyWaitTimeout = [configDictionary[kUnityServicesConfigPrivacyWaitTimeout] longLongValue] ? : 3000; //prwto
    self.experiments = [UADSConfigurationExperiments newWithJSON: experimentsDictionary];
    self.sessionToken = configDictionary[kUnityServicesConfigSessionToken] ? : nil;
    self.enableNativeMetrics = self.metricSamplingRate >= (arc4random_uniform(99) + 1);
    self.originalJSON = [NSDictionary uads_dictionaryByMerging: @{@"enableNativeMetrics": @(self.enableNativeMetrics)}
                                                     secondary: configDictionary];
    
    
    self.scarHbUrl = configDictionary[kUnityServicesConfigValueScarHbUrl] ? : nil;
}

- (NSArray<NSString *> *)getWebAppApiClassList {
    return [USRVConfigurationStorage.sharedInstance getWebAppApiClassList];
}

- (NSArray<NSString *> *)getModuleConfigurationList {
    return [USRVConfigurationStorage.sharedInstance getModuleConfigurationList];
}

- (USRVModuleConfiguration *)getModuleConfiguration: (NSString *)moduleName {
    return [USRVConfigurationStorage.sharedInstance getModuleConfiguration: moduleName];
}

- (NSData *)toJson {
    NSError *error;

    // Nil values cannot be added to the dictionary, and NSNull is used in its place
    NSDictionary *configDictionary = @{
        kUnityServicesConfigValueUrl: self.webViewUrl ? : [NSNull null],
        kUnityServicesConfigValueHash:  self.webViewHash ? : [NSNull null],
        kUnityServicesConfigValueVersion: self.webViewVersion ? : [NSNull null],
        kUnityServicesConfigValueDelayWebviewUpdate: [NSNumber numberWithBool: self.delayWebViewUpdate],
        kUnityServicesConfigValueResetWebAppTimeout: [NSNumber numberWithInt: self.resetWebAppTimeout],
        kUnityServicesConfigValueMaxRetries: [NSNumber numberWithLong: self.maxRetries],
        kUnityServicesConfigValueRetryDelay: [NSNumber numberWithLong: self.retryDelay],
        kUnityServicesConfigValueRetryScalingFactor: [NSNumber numberWithDouble: self.retryScalingFactor],
        kUnityServicesConfigValueConnectedEventThreshold: [NSNumber numberWithInt: self.connectedEventThresholdInMs],
        kUnityServicesConfigValueMaximumConnectedEvents: [NSNumber numberWithInt: self.maximumConnectedEvents],
        kUnityServicesConfigValueNetworkErrorTimeout: [NSNumber numberWithLong: self.networkErrorTimeout],
        kUnityServicesConfigValueMetricsUrl: self.metricsUrl ? : [NSNull null],
        kUnityServicesConfigValueMetricSamplingRate: [NSNumber numberWithDouble: self.metricSamplingRate],
        kUnityServicesConfigValueShowTimeout: [NSNumber numberWithInt: self.showTimeout],
        kUnityServicesConfigValueLoadTimeout: [NSNumber numberWithInt: self.loadTimeout],
        kUnityServicesConfigValueWebViewTimeout: [NSNumber numberWithInt: self.webViewTimeout],
        kUnityServicesConfigValueWebViewAppCreateTimeout: [NSNumber numberWithLong: self.webViewAppCreateTimeout],
        kUnityServicesConfigHeaderBiddingTimeout: [NSNumber numberWithLong: self.hbTokenTimeout],
        kUnityServicesConfigValueSdkVersion: self.sdkVersion ? : [NSNull null],
        kUnityServicesConfigHeaderBiddingTimeout: [NSNumber numberWithLong: self.hbTokenTimeout],
        kUnityServicesConfigPrivacyWaitTimeout: [NSNumber numberWithLong: self.privacyWaitTimeout],
        kUnityServicesConfigValueSource: self.source ? : [NSNull null]
    };

    NSMutableDictionary *mConfigDictionary = [NSMutableDictionary dictionaryWithDictionary: configDictionary];
    [mConfigDictionary uads_setValueIfNotNil:[_originalJSON valueForKey: kUnityServicesConfigValueExperiments]
                                      forKey:kUnityServicesConfigValueExperiments];
    [mConfigDictionary uads_setValueIfNotNil:[_originalJSON valueForKey: kUnityServicesConfigValueExperimentsObject]
                                      forKey:kUnityServicesConfigValueExperimentsObject];
    
    [mConfigDictionary uads_setValueIfNotNil:self.scarHbUrl
                                      forKey:kUnityServicesConfigValueScarHbUrl];
    
    // TODO: Handle JSON Serialization Error
    return [NSJSONSerialization dataWithJSONObject: mConfigDictionary
                                           options: kNilOptions
                                             error: &error];
} /* toJson */

- (void)saveToDisk {
    if (self.hasValidWebViewURL) {
        [[self toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                        atomically: YES];
    }
}

- (BOOL)hasValidWebViewURL {
    NSString *url = self.webViewUrl;

    return url != nil && ![url isEqual: @""] && ![url isKindOfClass: [NSNull class]];
}

@end
