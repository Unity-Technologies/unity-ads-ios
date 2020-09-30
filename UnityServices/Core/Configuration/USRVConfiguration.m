#import "USRVConfiguration.h"
#import "USRVSdkProperties.h"
#import "USRVWebRequest.h"
#import "USRVWebRequestFactory.h"

NSString* const kUnityServicesConfigValueHash = @"hash";
NSString* const kUnityServicesConfigValueUrl = @"url";
NSString* const kUnityServicesConfigValueVersion = @"version";
NSString* const kUnityServicesConfigValueDelayWebviewUpdate = @"dwu";
NSString* const kUnityServicesConfigValueResetWebAppTimeout = @"rwt";
NSString* const kUnityServicesConfigValueMaxRetries = @"mr";
NSString* const kUnityServicesConfigValueRetryDelay = @"rd";
NSString* const kUnityServicesConfigValueRetryScalingFactor = @"rcf";
NSString* const kUnityServicesConfigValueConnectedEventThreshold = @"cet";
NSString* const kUnityServicesConfigValueMaximumConnectedEvents = @"mce";
NSString* const kUnityServicesConfigValueNetworkErrorTimeout = @"net";
NSString* const kUnityServicesConfigValueMetricsUrl = @"murl";
NSString* const kUnityServicesConfigValueMetricSamplingRate = @"msr";
NSString* const kUnityServicesConfigValueShowTimeout = @"sto";
NSString* const kUnityServicesConfigValueLoadTimeout = @"lto";
NSString* const kUnityServicesConfigValueNoFillTimeout = @"nft";
NSString* const kUnityServicesConfigValueWebViewAppCreateTimeout = @"wct";
NSString* const kUnityServicesConfigValueSdkVerion = @"sdkv";

NSArray<NSString*>* moduleConfigurationList;
NSMutableDictionary<NSString*, USRVModuleConfiguration *>* moduleConfigurations;
NSArray<NSString*>* webAppApiClassList;

@implementation USRVConfiguration

- (instancetype)initWithConfigUrl:(NSString *)url {
    self = [self init];
    self.configUrl = url;
    return self;
}

- (instancetype)initWithConfigJsonData:(NSData *)configJsonData {
    if (configJsonData == nil) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        [self createModuleConfigurationList];
        [self handleConfigurationData:configJsonData];
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self createModuleConfigurationList];
        [self setOptionalFields:[[NSDictionary alloc] init]];
    }

    return self;
}

- (NSString *)buildQueryString {
    long long ts = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"?ts=%lld&sdkVersion=%d&sdkVersionName=%@", ts, [USRVSdkProperties getVersionCode], [USRVSdkProperties getVersionName]];
}

- (void)makeRequest {
    
    if (self.configUrl == nil) {
        [self setError:@"ERROR_NIL_CONFIG_URL"];
        USRVLogError(@"Native Configuration request missing URL");
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self configUrl], [self buildQueryString]];
    USRVLogDebug(@"Requesting configuration with: %@", urlString);

    [self setError:nil];
    id<USRVWebRequest> request = [USRVWebRequestFactory create:urlString requestType:@"GET" headers:NULL connectTimeout:30000];
    NSData *responseData = [request makeRequest];
    
    if (request.error) {
        [self setError:@"ERROR_REQUESTING_CONFIG"];
        USRVLogError(@"Native Configuration request failed");
        return;
    }
    
    [self handleConfigurationData:responseData];
}

- (void)handleConfigurationData:(NSData *)configData {
    NSError *error;
    NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData:configData options:kNilOptions error:&error];
    
    if (error) {
        [self setError:@"ERROR_PARSING_CONFIG_RESPONSE"];
        USRVLogError(@"Native Configuration parsing failed");
        return;
    }
    
    USRVLogDebug(@"Fetched Native Configuration: %@", [configDictionary description]);
    
    NSString* webviewUrl = configDictionary[kUnityServicesConfigValueUrl];
    if (webviewUrl == nil || [webviewUrl isEqualToString:@""]) {
        [self setError:@"ERROR_NIL_REQUIRED_CONFIGURATION_FIELDS"];
        USRVLogError(@"Native Configuration Webview URL Field Missing");
        return;
    }
    self.webViewUrl = webviewUrl;
    
    [self setOptionalFields:configDictionary];
}

- (void)setOptionalFields:(NSDictionary *)configDictionary {
    self.webViewHash = configDictionary[kUnityServicesConfigValueHash] ?: nil;
    self.webViewVersion = configDictionary[kUnityServicesConfigValueVersion] ?: nil;
    self.delayWebViewUpdate = [configDictionary[kUnityServicesConfigValueDelayWebviewUpdate] boolValue] ?: NO;
    self.resetWebAppTimeout = [configDictionary[kUnityServicesConfigValueResetWebAppTimeout] intValue] ?: 10000;
    self.maxRetries = [configDictionary[kUnityServicesConfigValueMaxRetries] intValue] ?: 6;
    self.retryDelay = [configDictionary[kUnityServicesConfigValueRetryDelay] longValue] ?: 5000L;
    self.retryScalingFactor= [configDictionary[kUnityServicesConfigValueRetryScalingFactor] doubleValue] ?: 2.0;
    self.connectedEventThresholdInMs = [configDictionary[kUnityServicesConfigValueConnectedEventThreshold] intValue] ?: 10000;
    self.maximumConnectedEvents = [configDictionary[kUnityServicesConfigValueMaximumConnectedEvents] intValue] ?: 500;
    self.networkErrorTimeout = [configDictionary[kUnityServicesConfigValueNetworkErrorTimeout] longValue] ?: 60000L;
    self.metricsUrl = configDictionary[kUnityServicesConfigValueMetricsUrl] ?: nil;
    self.metricSamplingRate = [configDictionary[kUnityServicesConfigValueMetricSamplingRate] doubleValue] ?: 100;
    self.showTimeout = [configDictionary[kUnityServicesConfigValueShowTimeout] intValue] ?: 5000;
    self.loadTimeout = [configDictionary[kUnityServicesConfigValueLoadTimeout] intValue] ?: 5000;
    self.noFillTimeout = [configDictionary[kUnityServicesConfigValueNoFillTimeout] intValue] ?: 30000;
    self.webViewAppCreateTimeout = [configDictionary[kUnityServicesConfigValueWebViewAppCreateTimeout] longValue] ?: 60000L;
    self.sdkVersion = configDictionary[kUnityServicesConfigValueSdkVerion] ?: nil;
}

- (NSArray<NSString*>*)getWebAppApiClassList {
    if (!webAppApiClassList) {
        [self createWebAppApiClassList];
    }
    
    return webAppApiClassList;
}

- (NSArray<NSString*>*)getModuleConfigurationList {
    return moduleConfigurationList;
}

- (USRVModuleConfiguration *)getModuleConfiguration:(NSString *)moduleName {
    if (moduleConfigurations && [moduleConfigurations objectForKey:moduleName]) {
        return [moduleConfigurations objectForKey:moduleName];
    }
    else {
        if (!moduleConfigurations) {
            moduleConfigurations = [[NSMutableDictionary alloc] init];
        }

        id clz = NSClassFromString(moduleName);
        if (clz) {
            id obj = [[NSClassFromString(moduleName) alloc] init];
            if (obj) {
                if ([obj respondsToSelector:@selector(getWebAppApiClassList)]) {
                    USRVLogDebug(@"Responds to selector");
                    [moduleConfigurations setObject:obj forKey:moduleName];
                    return obj;
                }
            }
            else {
                USRVLogDebug(@"Object not created");
                return NULL;
            }
        }
        else {
            USRVLogDebug(@"Class not found");
            return NULL;
        }
    }

    return NULL;
}

- (void)createWebAppApiClassList {
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    
    for (NSString *moduleConfigClass in [self getModuleConfigurationList]) {
        id moduleConfiguration = [self getModuleConfiguration:moduleConfigClass];
        if (moduleConfiguration) {
            if ([moduleConfiguration getWebAppApiClassList]) {
                [tmpArray addObjectsFromArray:[moduleConfiguration getWebAppApiClassList]];
            }
        }
    }
    
    webAppApiClassList = [[NSArray alloc] initWithArray:tmpArray];
}

- (void)createModuleConfigurationList {
    moduleConfigurationList = @[
        @"USRVCoreModuleConfiguration",
        @"UADSAdsModuleConfiguration",
        @"UANAAnalyticsModuleConfiguration",
        @"UMONMonetizationModuleConfiguration",
        @"UPURPurchasingModuleConfiguration",
        @"UADSBannerModuleConfiguration",
        @"UADSARModuleConfiguration",
        @"USTRStoreModuleConfiguration"
    ];
}

- (NSData*) toJson {
    NSError* error;
    
    // Nil values cannot be added to the dictionary, and NSNull is used in its place
    NSDictionary *configDictionary = @{
        kUnityServicesConfigValueUrl : self.webViewUrl ?: [NSNull null],
        kUnityServicesConfigValueHash :  self.webViewHash ?: [NSNull null],
        kUnityServicesConfigValueVersion : self.webViewVersion ?: [NSNull null],
        kUnityServicesConfigValueDelayWebviewUpdate : [NSNumber numberWithBool:self.delayWebViewUpdate],
        kUnityServicesConfigValueResetWebAppTimeout : [NSNumber numberWithInt:self.resetWebAppTimeout],
        kUnityServicesConfigValueMaxRetries : [NSNumber numberWithLong:self.maxRetries],
        kUnityServicesConfigValueRetryDelay : [NSNumber numberWithLong:self.retryDelay],
        kUnityServicesConfigValueRetryScalingFactor : [NSNumber numberWithDouble:self.retryScalingFactor],
        kUnityServicesConfigValueConnectedEventThreshold : [NSNumber numberWithInt:self.connectedEventThresholdInMs],
        kUnityServicesConfigValueMaximumConnectedEvents : [NSNumber numberWithInt:self.maximumConnectedEvents],
        kUnityServicesConfigValueNetworkErrorTimeout : [NSNumber numberWithLong:self.networkErrorTimeout],
        kUnityServicesConfigValueMetricsUrl : self.metricsUrl ?: [NSNull null],
        kUnityServicesConfigValueMetricSamplingRate : [NSNumber numberWithDouble:self.metricSamplingRate],
        kUnityServicesConfigValueShowTimeout: [NSNumber numberWithInt:self.showTimeout],
        kUnityServicesConfigValueLoadTimeout: [NSNumber numberWithInt:self.loadTimeout],
        kUnityServicesConfigValueNoFillTimeout: [NSNumber numberWithInt:self.noFillTimeout],
        kUnityServicesConfigValueWebViewAppCreateTimeout : [NSNumber numberWithLong:self.webViewAppCreateTimeout],
        kUnityServicesConfigValueSdkVerion : self.sdkVersion ?: [NSNull null]
    };

    // TODO: Handle JSON Serialization Error
    return [NSJSONSerialization dataWithJSONObject:configDictionary options:kNilOptions error:&error];
}

@end
