

FOUNDATION_EXPORT NSString * const kUnityAdsConfigValueUrl;
FOUNDATION_EXPORT NSString * const kUnityAdsConfigValueHash;

@interface UADSConfiguration : NSObject

@property (nonatomic, strong) NSString *webViewUrl;
@property (nonatomic, strong) NSString *webViewHash;
@property (nonatomic, strong) NSString *webViewData;
@property (nonatomic, strong) NSString *configUrl;
@property (nonatomic, strong) NSString *webViewVersion;
@property (nonatomic, strong) NSArray<NSString*> *webAppApiClassList;
@property (nonatomic, strong) NSString *error;

- (instancetype)initWithConfigUrl:(NSString *)url;
- (void)makeRequest;

@end