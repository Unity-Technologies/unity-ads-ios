#import "UnityAds.h"
#import "UADSConfiguration.h"
#import "UADSSdkProperties.h"
#import "UADSWebRequest.h"

NSString* const kUnityAdsConfigValueHash = @"hash";
NSString* const kUnityAdsConfigValueUrl = @"url";
NSString* const kUnityAdsConfigValueVersion = @"version";

@implementation UADSConfiguration

- (instancetype)initWithConfigUrl:(NSString *)url {
    self = [super init];
    
    if (self) {
        _configUrl = url;
    }
    
    return self;
}

- (NSString *)buildQueryString {
    long ts = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"?ts=%ld&sdkVersion=%d&sdkVersionName=%@", ts, [UADSSdkProperties getVersionCode], [UADSSdkProperties getVersionName]];
}

- (void)makeRequest {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self configUrl], [self buildQueryString]];
    UADSLogDebug(@"Requesting configuration with: %@", urlString);

    [self setError:nil];
    NSError *error;
    UADSWebRequest *request = [[UADSWebRequest alloc] initWithUrl:urlString requestType:@"GET" headers:NULL connectTimeout:30000];
    NSData *responseData = [request makeRequest];
    
    if (!request.error) {
        NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if (!error) {
            UADSLogDebug(@"Fetched config: %@", [configDictionary description]);
            [self setWebViewHash:configDictionary[kUnityAdsConfigValueHash]];
            [self setWebViewUrl:configDictionary[kUnityAdsConfigValueUrl]];
            [self setWebViewVersion:configDictionary[kUnityAdsConfigValueVersion]];
        }
        else {
            [self setError:@"ERROR_PARSING_CONFIG_RESPONSE"];
        }
    }
    else {
        [self setError:@"ERROR_REQUESTING_CONFIG"];
        UADSLogDebug(@"Configuration request failed");
    }
}

@end