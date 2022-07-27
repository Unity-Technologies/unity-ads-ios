#import "USRVInitializationRequestFactory.h"
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

@interface USRVInitializationRequestFactoryBase ()
@property (nonatomic, strong) id<USRVDataCompressor>dataCompressor;
@property (nonatomic, strong) id<UADSDeviceInfoReader>infoReader;
@property (nonatomic, strong) id<UADSBaseURLBuilder> urlBaseBuilder;
@property (nonatomic, strong) id<UADSConfigurationRequestFactoryConfig> config;
@property (nonatomic, strong) id<IUSRVWebRequestFactory> webRequestFactory;
@property (nonatomic, strong) id<UADSCurrentTimestamp> timeStampReader;
@property (nonatomic, assign) int connectTimeout;
@end

NSString * uads_requestTypeString(USRVInitializationRequestType type) {
    switch (type) {
        case USRVInitializationRequestTypeToken:
            return @"token";

        case USRVInitializationRequestTypePrivacy:
            return @"privacy";

        default:
            assert(1);
    }
}

@implementation USRVInitializationRequestFactoryBase

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                      andDataCompressor: (id<USRVDataCompressor>)dataCompressor
                         andBaseBuilder: (id<UADSBaseURLBuilder>)urlBaseBuilder
                   andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory
                       andFactoryConfig: (id<UADSConfigurationRequestFactoryConfig>)config
                     andTimeStampReader: (id<UADSCurrentTimestamp>)timeStampReader {
    USRVInitializationRequestFactoryBase *base = [self new];

    base.dataCompressor = dataCompressor;
    base.infoReader = deviceInfoReader;
    base.urlBaseBuilder = urlBaseBuilder;
    base.config = config;
    base.connectTimeout = 30000;
    base.webRequestFactory = webRequestFactory;
    base.timeStampReader = timeStampReader;
    return base;
}

- (id<USRVWebRequest>)requestOfType: (USRVInitializationRequestType)type {
    NSDictionary *deviceInfoBody = [self bodyAsDictionaryForMode: type];

    return [self createPOSTRequestFor: deviceInfoBody];
}

- (NSString *)baseURL {
    return _urlBaseBuilder.baseURL;
}

- (id<USRVWebRequest>)createPOSTRequestFor: (NSDictionary *)deviceInfo {
    NSString *urlString = [self configURLStringForUsingQueryDictionary: @{}];

    GUARD_OR_NIL(urlString);
    id<USRVWebRequest> request = [self.webRequestFactory create: urlString
                                                    requestType: @"POST"
                                                        headers: @{ @"Content-Encoding": @[@"gzip"],
                                                                    @"Content-Type": @[@"application/json"] }
                                                 connectTimeout: self.connectTimeout];

    if (self.dataCompressor && !deviceInfo.uads_isEmpty) {
        request.bodyData = [self.dataCompressor compressedIntoData: deviceInfo];
    }

    return request;
}

- (NSString *)configURLStringForUsingQueryDictionary: (NSDictionary *)queryAttributes {
    GUARD_OR_NIL(self.baseURL);

    NSString *query = queryAttributes.uads_queryString;

    query = [query stringByAddingPercentEncodingWithAllowedCharacters: NSCharacterSet.URLQueryAllowedCharacterSet];
    return [NSString stringWithFormat: @"%@%@", self.baseURL, query];
}

- (NSDictionary *)bodyAsDictionaryForMode: (USRVInitializationRequestType)type {
    if (!self.infoReader) {
        return @{};
    }

    NSMutableDictionary *bodyDictionary = [NSMutableDictionary dictionaryWithDictionary: [_infoReader getDeviceInfoForGameMode: UADSGameModeMix]];

    if (!bodyDictionary.uads_isEmpty) {
        bodyDictionary[@"callType"] = uads_requestTypeString(type);
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
    mDictionary[ @"sdkVersionName"] = _config.sdkVersionName ? : @"";
    return mDictionary;
}

- (NSNumber *)currentTimeStamp {
    return @(round(_timeStampReader.currentTimestamp * 1000));
}

@end
