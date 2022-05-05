#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSHeaderBiddingTokenReaderWithSerialQueue.h"
#import "UADSHeaderBiddingTokenReaderBase.h"
#import "UADSDeviceInfoReaderBuilder.h"
#import "USRVSDKMetrics.h"
#import "USRVDictionaryCompressorWithMetrics.h"
#import "UADSTools.h"
#import "UADSHeaderBiddingTokenReaderWithMetrics.h"
#import "USRVDataGzipCompressor.h"
#import "UADSServiceProvider.h"

@interface UADSHeaderBiddingTokenReaderBuilder ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>tokenReader;
@end


@implementation UADSHeaderBiddingTokenReaderBuilder

_uads_default_singleton_imp(UADSHeaderBiddingTokenReaderBuilder);

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)defaultReader {
    @synchronized (self) {
        if (_tokenReader) {
            return _tokenReader;
        }

        id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> reader;

        reader = [UADSHeaderBiddingTokenReaderBridge newWithNativeTokenGenerator: self.tokenGenerator
                                                                    andTokenCRUD: self.tokenCRUD
                                                          andConfigurationReader: self.sdkConfigReader];

        reader = [UADSHeaderBiddingTokenReaderWithSerialQueue newWithOriginalReader: reader
                                                                    andStatusReader: self.sdkInitializationStatusReader];

        reader = [UADSHeaderBiddingTokenReaderWithMetrics decorateOriginal: reader
                                                           andStatusReader: self.sdkInitializationStatusReader
                                                             metricsSender: self.metricsSender
                                                                tagsReader: self.sdkConfigReader];

        _tokenReader = reader;
    }
    return _tokenReader;
}

- (id<UADSDeviceInfoReader>)deviceInfoReader {
    if (_deviceInfoReader) {
        return _deviceInfoReader;
    }

    UADSDeviceInfoReaderBuilder *builder = [UADSDeviceInfoReaderBuilder new];
    UADSConfigurationRequestFactoryConfigBase *config = [UADSConfigurationRequestFactoryConfigBase defaultWithExperiments: self.sdkConfigReader.getCurrentConfiguration.experiments];

    _deviceInfoReader = [builder defaultReaderWithConfig: config
                                           metricsSender: self.metricsSender
                                        metricTagsReader: self.sdkConfigReader];
    return _deviceInfoReader;
}

- (id<ISDKMetrics>)metricsSender {
    if (_metricsSender) {
        return _metricsSender;
    }

    _metricsSender = UADSServiceProvider.sharedInstance.metricSender;
    return _metricsSender;
}

- (id<USRVStringCompressor>)bodyCompressor {
    if (_bodyCompressor) {
        return _bodyCompressor;
    }

    id<USRVDataCompressor> gzipCompressor = [USRVDataGzipCompressor new];

    gzipCompressor = [USRVDictionaryCompressorWithMetrics defaultDecorateOriginal: gzipCompressor
                                                                 andMetricsSender: self.metricsSender
                                                                       tagsReader: self.sdkConfigReader];

    _bodyCompressor = [USRVBodyBase64GzipCompressor newWithDataCompressor: gzipCompressor];
    return _bodyCompressor;
}

- (id<UADSConfigurationReader, UADSConfigurationMetricTagsReader>)sdkConfigReader {
    if (_sdkConfigReader) {
        return _sdkConfigReader;
    }

    _sdkConfigReader = [UADSConfigurationCRUDBase new];
    return _sdkConfigReader;
}

- (id<UADSHeaderBiddingTokenCRUD>)tokenCRUD {
    if (_tokenCRUD) {
        return _tokenCRUD;
    }

    _tokenCRUD = [UADSTokenStorage sharedInstance];
    return _tokenCRUD;
}

- (id<UADSHeaderBiddingAsyncTokenReader>)tokenGenerator {
    if (_tokenGenerator) {
        return _tokenGenerator;
    }

    _tokenGenerator = [UADSHeaderBiddingTokenReaderBase newWithDeviceInfoReader: self.deviceInfoReader
                                                                  andCompressor: self.bodyCompressor];
    return _tokenGenerator;
}

- (id<UADSInitializationStatusReader>)sdkInitializationStatusReader {
    if (_sdkInitializationStatusReader) {
        return _sdkInitializationStatusReader;
    }

    _sdkInitializationStatusReader = [UADSInitializationStatusReaderBase new];
    return _sdkInitializationStatusReader;
}

@end
