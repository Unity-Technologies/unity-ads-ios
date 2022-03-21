#import "USRVConfigurationRequestFactory.h"
#import "USRVSdkProperties.h"
#import "UADSTools.h"
#import "USRVWebRequestFactory.h"
#import "USRVClientProperties.h"
#import "USRVBodyURLEncodedCompressorDecorator.h"
#import "NSDictionary+Merge.h"
#import "NSDictionary+JSONString.h"
#import "UADSDeviceInfoReaderWithStorageInfo.h"
#import "UADSDeviceInfoReaderWithFilter.h"
#import "UADSDeviceInfoReaderBuilder.h"
#import "UADSDeviceInfoReaderKeys.h"
#import "USRVDevice.h"
#import "USRVSDKMetrics.h"
#import "USRVDictionaryCompressorWithMetrics.h"
#import "USRVDataGzipCompressor.h"
#import "USRVStorageManager.h"


@interface USRVConfigurationRequestFactoryBase ()
@property (nonatomic, strong) id<USRVStringCompressor>stringCompressor;
@property (nonatomic, strong) id<USRVDataCompressor>dataCompressor;
@property (nonatomic, strong) id<UADSDeviceInfoReader>infoReader;
@property (nonatomic, strong) id<UADSBaseURLBuilder> urlBaseBuilder;
@property (nonatomic, strong) id<UADSConfigurationRequestFactoryConfig> config;
@property (nonatomic, strong) id<IUSRVWebRequestFactory> webRequestFactory;
@property (nonatomic, assign) int connectTimeout;
@end

#define USE_QUERIES false
@implementation USRVConfigurationRequestFactoryBase

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                      andDataCompressor: (id<USRVDataCompressor>)dataCompressor
                    andStringCompressor: (id<USRVStringCompressor>)compressor
                         andBaseBuilder: (id<UADSBaseURLBuilder>)urlBaseBuilder
                   andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory
                       andFactoryConfig: (id<UADSConfigurationRequestFactoryConfig>)config {
    USRVConfigurationRequestFactoryBase *base = [self new];

    base.dataCompressor = dataCompressor;
    base.stringCompressor = compressor;
    base.infoReader = deviceInfoReader;
    base.urlBaseBuilder = urlBaseBuilder;
    base.config = config;
    base.connectTimeout = 30000;
    base.webRequestFactory = webRequestFactory;
    return base;
}

+ (instancetype)newWithCompression: (BOOL)shouldCompress
               andDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                    andBaseBuilder: (id<UADSBaseURLBuilder>)urlBaseBuilder
                  andFactoryConfig: (id<UADSConfigurationRequestFactoryConfig>)config
                     metricsSender: (id<ISDKMetrics>)metricsSender
                  metricTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader {
    id<USRVDataCompressor> dataCompressor;
    id<USRVStringCompressor> compressor;

    if (shouldCompress) {
        dataCompressor =  [self dataCompressorWithMetricsSender: metricsSender
                                               metricTagsReader: tagsReader];
        compressor = [self compressorWithGzip: dataCompressor];
    }

    return [self newWithDeviceInfoReader: deviceInfoReader
                       andDataCompressor: dataCompressor
                     andStringCompressor: compressor
                          andBaseBuilder: urlBaseBuilder
                    andWebRequestFactory: [USRVWebRequestFactory new]
                        andFactoryConfig: config];
}

+ (instancetype)defaultFactoryWithConfig: (id<UADSConfigurationRequestFactoryConfig, UADSPIIDataSelectorConfig>)config
                    andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory
                           metricsSender: (id<ISDKMetrics>)metricsSender
                        metricTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader {
    id<UADSDeviceInfoReader> deviceInfoReader = [[UADSDeviceInfoReaderBuilder new] defaultReaderWithConfig: config
                                                                                             metricsSender: metricsSender
                                                                                          metricTagsReader: tagsReader];
    id<USRVDataCompressor> dataCompressor = [self dataCompressorWithMetricsSender: metricsSender
                                                                 metricTagsReader: tagsReader];
    id<USRVStringCompressor> compressor = [self compressorWithGzip: dataCompressor];
    id<UADSHostnameProvider>hostProvider = UADSConfigurationEndpointProvider.defaultProvider;
    id<UADSBaseURLBuilder> urlBaseBuilder =  [UADSBaseURLBuilderBase newWithHostNameProvider: hostProvider];

    return [self newWithDeviceInfoReader: deviceInfoReader
                       andDataCompressor: dataCompressor
                     andStringCompressor: compressor
                          andBaseBuilder: urlBaseBuilder
                    andWebRequestFactory: webRequestFactory
                        andFactoryConfig: config];
}

+ (id<USRVStringCompressor>)compressorWithGzip: (id<USRVDataCompressor>)dataCompressor {
    id<USRVStringCompressor> compressor = [USRVBodyBase64GzipCompressor newWithDataCompressor: dataCompressor];

    compressor = [USRVBodyURLEncodedCompressorDecorator decorateOriginal: compressor];
    return compressor;
}

+ (id<USRVDataCompressor>)dataCompressorWithMetricsSender: (id<ISDKMetrics>)metricsSender
                                         metricTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader {
    id<USRVDataCompressor> dataCompressor = [USRVDataGzipCompressor new];

    dataCompressor = [USRVDictionaryCompressorWithMetrics defaultDecorateOriginal: dataCompressor
                                                                 andMetricsSender: metricsSender
                                                                       tagsReader: tagsReader];
    return dataCompressor;
}

- (id<USRVWebRequest>)configurationRequestFor: (UADSGameMode)mode {
    NSDictionary *deviceInfoBody = self.config.isTwoStageInitializationEnabled ? [self bodyAsDictionaryForMode: mode] : @{};

    if (self.config.isPOSTMethodInConfigRequestEnabled) {
        return [self createPOSTRequestFor: deviceInfoBody];
    } else {
        return [self createGetRequestFor: deviceInfoBody];
    }
}

- (NSString *)baseURL {
    return _urlBaseBuilder.baseURL;
}

- (id<USRVWebRequest>)createGetRequestFor: (NSDictionary *)deviceInfo {
    NSDictionary *queryDictionary = [self constructQueryParamsUsing: deviceInfo];
    NSString *urlString = [self configURLStringForUsingQueryDictionary: queryDictionary];

    GUARD_OR_NIL(urlString);
    return [self.webRequestFactory create: urlString
                              requestType: @"GET"
                                  headers: NULL
                           connectTimeout: self.connectTimeout];
}

- (id<USRVWebRequest>)createPOSTRequestFor: (NSDictionary *)deviceInfo {
    NSString *urlString = [self configURLStringForUsingQueryDictionary: @{}];

    GUARD_OR_NIL(urlString);
    id<USRVWebRequest> request = [self.webRequestFactory create: urlString
                                                    requestType: @"POST"
                                                        headers: @{ @"Content-Encoding": @[@"gzip"],
                                                                    @"Content-Type": @[@"application/json"] }
                                                 connectTimeout: self.connectTimeout];

    if (self.dataCompressor && !deviceInfo.isEmpty) {
        request.bodyData = [self.dataCompressor compressedIntoData: deviceInfo];
    }

    return request;
}

- (NSString *)configURLStringForUsingQueryDictionary: (NSDictionary *)queryAttributes {
    GUARD_OR_NIL(self.baseURL);
    NSString *query = queryAttributes.queryString;

    if (self.stringCompressor == nil) {
        query = [query stringByAddingPercentEncodingWithAllowedCharacters: NSCharacterSet.URLQueryAllowedCharacterSet];
    }

    return [NSString stringWithFormat: @"%@%@", self.baseURL, query];
}

- (NSDictionary *)constructQueryParamsUsing: (NSDictionary *)deviceInfo {
    NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary: self.queryAttributes];


    if (self.stringCompressor && !deviceInfo.isEmpty) {
        NSString *compressedBody = [self.stringCompressor compressedIntoString: deviceInfo];
        mDictionary[@"c"] = compressedBody;
        return mDictionary;
    } else {
        //this is the flow can be used for testing to see if arguments are passed correctly
        return [NSDictionary unityads_dictionaryByMerging: mDictionary
                                                secondary: deviceInfo];
    }
}

- (NSDictionary *)bodyAsDictionaryForMode: (UADSGameMode)mode {
    if (!self.infoReader) {
        return @{};
    }

    NSMutableDictionary *bodyDictionary = [NSMutableDictionary dictionaryWithDictionary: [_infoReader getDeviceInfoForGameMode: mode]];

    if (!bodyDictionary.isEmpty) {
        bodyDictionary[@"callType"] = @"token";
        return [self appendCommonValuesTo: bodyDictionary];
    }

    return bodyDictionary;
}

- (NSDictionary *)queryAttributes {
    NSDictionary *newDictionary = [NSDictionary new];

    if (!_config.isTwoStageInitializationEnabled) {
        NSMutableDictionary *mDictionary = [NSMutableDictionary new];
        mDictionary[@"ts"] = self.currentTimeStamp;
        mDictionary[@"sdkVersion"] = _config.sdkVersion ? : @"";
        newDictionary = [self appendCommonValuesTo: mDictionary];
    }

    return newDictionary;
}

- (NSDictionary *)appendCommonValuesTo: (NSDictionary *)dictionary {
    NSMutableDictionary *mDictionary = [[NSMutableDictionary alloc] initWithDictionary: dictionary];

    mDictionary[kUADSDeviceInfoGameIDKey] = _config.gameID ? : @"";
    mDictionary[ @"sdkVersionName"] = _config.sdkVersionName ? : @"";
    return mDictionary;
}

- (NSNumber *)currentTimeStamp {
    return [USRVDevice currentTimeStamp];
}

@end
