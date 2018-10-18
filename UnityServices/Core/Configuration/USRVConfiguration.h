FOUNDATION_EXPORT NSString * const kUnityServicesConfigValueUrl;
FOUNDATION_EXPORT NSString * const kUnityServicesConfigValueHash;

@class USRVModuleConfiguration;

@interface USRVConfiguration : NSObject

@property (nonatomic, strong) NSString *webViewUrl;
@property (nonatomic, strong) NSString *webViewHash;
@property (nonatomic, strong) NSString *webViewData;
@property (nonatomic, strong) NSString *configUrl;
@property (nonatomic, strong) NSString *webViewVersion;
@property (nonatomic, strong) NSString *error;

- (instancetype)initWithConfigUrl:(NSString *)url;
- (void)makeRequest;
- (NSArray<NSString*>*)getWebAppApiClassList;
- (NSArray<NSString*>*)getModuleConfigurationList;
- (USRVModuleConfiguration *)getModuleConfiguration:(NSString *)moduleName;

@end
