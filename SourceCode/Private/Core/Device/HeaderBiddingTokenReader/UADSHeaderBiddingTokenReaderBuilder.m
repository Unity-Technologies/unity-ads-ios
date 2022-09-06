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
#import "UADSHBTokenReaderWithPrivacyWait.h"

static NSString *const kDefaultTokenPrefix = @"1:";

@interface UADSHeaderBiddingTokenReaderBuilder ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>tokenReader;
@end


@implementation UADSHeaderBiddingTokenReaderBuilder


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
                                                     privacyResponseReader: self.privacyStorage];

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

    builder.selectorConfig = config;
    builder.metricsSender = self.metricsSender;
    builder.privacyReader = self.privacyStorage;
    builder.extendedReader = true;
    builder.currentTimeStampReader = [UADSCurrentTimestampBase new];
    _deviceInfoReader = builder.defaultReader;
    return _deviceInfoReader;
}

- (id<USRVStringCompressor>)bodyCompressor {
    if (_bodyCompressor) {
        return _bodyCompressor;
    }

    id<USRVDataCompressor> gzipCompressor = [USRVDataGzipCompressor new];

    gzipCompressor = [USRVDictionaryCompressorWithMetrics defaultDecorateOriginal: gzipCompressor
                                                                 andMetricsSender: self.metricsSender];

    _bodyCompressor = [USRVBodyBase64GzipCompressor newWithDataCompressor: gzipCompressor];
    return _bodyCompressor;
}

- (id<UADSHeaderBiddingAsyncTokenReader>)tokenGenerator {
    if (!_tokenGenerator) {
        _tokenGenerator = [UADSHeaderBiddingTokenReaderBase newWithDeviceInfoReader: self.deviceInfoReader
                                                                      andCompressor: self.bodyCompressor
                                                                    withTokenPrefix: self.nativeTokenPrefix];
    }

    if (self.experiments.isPrivacyWaitEnabled) {
        _tokenGenerator = [UADSHBTokenReaderWithPrivacyWait newWithOriginal: _tokenGenerator
                                                          andPrivacySubject: self.privacyStorage
                                                                    timeout: self.currentConfig.privacyWaitTimeout / 1000];
    }

    return _tokenGenerator;
}

- (NSString *)nativeTokenPrefix {
    if (!_nativeTokenPrefix) {
        return kDefaultTokenPrefix;
    }

    return _nativeTokenPrefix;
}

- (id<UADSInitializationStatusReader>)sdkInitializationStatusReader {
    if (_sdkInitializationStatusReader) {
        return _sdkInitializationStatusReader;
    }

    _sdkInitializationStatusReader = [UADSInitializationStatusReaderBase new];
    return _sdkInitializationStatusReader;
}

- (UADSConfigurationExperiments *)experiments {
    return self.currentConfig.experiments;
}

- (USRVConfiguration *)currentConfig {
    return self.sdkConfigReader.getCurrentConfiguration;
}

@end
