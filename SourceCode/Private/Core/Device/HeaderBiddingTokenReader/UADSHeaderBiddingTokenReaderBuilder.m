#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSHeaderBiddingTokenReaderWithSerialQueue.h"
#import "UADSHeaderBiddingTokenReaderBase.h"
#import "UADSDeviceInfoReaderBuilder.h"
#import "USRVSDKMetrics.h"
#import "USRVDictionaryCompressorWithMetrics.h"
#import "UADSTools.h"
#import "UADSHeaderBiddingTokenReaderWithMetrics.h"
#import "USRVDataGzipCompressor.h"
#import "UADSServiceProviderContainer.h"
#import "UADSHBTokenReaderWithPrivacyWait.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignals.h"
#import "UADSUUIDStringGenerator.h"
#import "UADSHeaderBiddingTokenReaderSwiftBridge.h"

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

        if (self.scar.isAvailable) {
            UADSHeaderBiddingTokenReaderSCARSignalsConfig* tools = [UADSHeaderBiddingTokenReaderSCARSignalsConfig new];
            tools.signalService = self.scar.rawSignalService;
            tools.requestFactory = self.requestFactory;
            tools.compressor = self.bodyCompressor;
            tools.configurationReader = self.sdkConfigReader;
            tools.metricsSender = self.metricsSender;
            reader = [UADSHeaderBiddingTokenReaderWithSCARSignals decorateOriginal:reader withConfig:tools];
        }

        _tokenReader = reader;
    }
    return _tokenReader;
}

- (id<UADSDeviceInfoReader>)deviceInfoReader {
    if (_deviceInfoReader) {
        return _deviceInfoReader;
    }

    UADSDeviceInfoReaderBuilder *builder = [UADSDeviceInfoReaderBuilder new];
    UADSCClientConfigBase *config = [UADSCClientConfigBase defaultWithExperiments: self.experiments];

    builder.clientConfig = config;
    builder.metricsSender = self.metricsSender;
    builder.privacyReader = self.privacyStorage;
    builder.extendedReader = true;
    builder.currentTimeStampReader = [UADSCurrentTimestampBase new];
    builder.gameSessionIdReader = self.gameSessionIdReader;
    builder.sharedSessionIdReader = self.sharedSessionIdReader;
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
        if (self.experiments.isSwiftTokenEnabled) {
            _tokenGenerator = [UADSHeaderBiddingTokenReaderSwiftBridge new];
        } else {
            _tokenGenerator = [UADSHeaderBiddingTokenReaderBase newWithDeviceInfoReader: self.deviceInfoReader
                                                                      andCompressor: self.bodyCompressor
                                                                    withTokenPrefix: self.nativeTokenPrefix
                                                              withUniqueIdGenerator: self.uniqueIdGenerator ?: [UADSUUIDStringGenerator new]
                                                            withConfigurationReader: self.sdkConfigReader];
        }
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
