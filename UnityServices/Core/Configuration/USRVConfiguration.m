#import "USRVConfiguration.h"
#import "USRVSdkProperties.h"
#import "USRVWebRequest.h"

NSString* const kUnityServicesConfigValueHash = @"hash";
NSString* const kUnityServicesConfigValueUrl = @"url";
NSString* const kUnityServicesConfigValueVersion = @"version";
NSArray<NSString*>* moduleConfigurationList;
NSMutableDictionary<NSString*, USRVModuleConfiguration *>* moduleConfigurations;
NSArray<NSString*>* webAppApiClassList;

@implementation USRVConfiguration

- (instancetype)initWithConfigUrl:(NSString *)url {
    self = [super init];
    
    if (self) {
        [self createModuleConfigurationList];
        _configUrl = url;
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self createModuleConfigurationList];
    }

    return self;
}

- (NSString *)buildQueryString {
    long long ts = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"?ts=%lld&sdkVersion=%d&sdkVersionName=%@", ts, [USRVSdkProperties getVersionCode], [USRVSdkProperties getVersionName]];
}

- (void)makeRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self configUrl], [self buildQueryString]];
    USRVLogDebug(@"Requesting configuration with: %@", urlString);

    [self setError:nil];
    NSError *error;
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:urlString requestType:@"GET" headers:NULL connectTimeout:30000];
    NSData *responseData = [request makeRequest];
    
    if (!request.error) {
        NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if (!error) {
            USRVLogDebug(@"Fetched config: %@", [configDictionary description]);
            [self setWebViewHash:configDictionary[kUnityServicesConfigValueHash]];
            [self setWebViewUrl:configDictionary[kUnityServicesConfigValueUrl]];
            [self setWebViewVersion:configDictionary[kUnityServicesConfigValueVersion]];
        }
        else {
            [self setError:@"ERROR_PARSING_CONFIG_RESPONSE"];
        }
    }
    else {
        [self setError:@"ERROR_REQUESTING_CONFIG"];
        USRVLogDebug(@"Configuration request failed");
    }
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
        @"UADSARModuleConfiguration"
    ];
}

@end
