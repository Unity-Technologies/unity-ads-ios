#import "UADSServiceProvider.h"
#import "UADSTools.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSConfigurationSaverWithTokenStorage.h"
#import "UADSMetricSenderWithBatch.h"
#import "USRVDeviceLog.h"
#import "UADSConfigurationLoaderBuilder.h"
#import "USRVStorageManager.h"
#import "UADSCurrentTimestampBase.h"

@interface UADSServiceProvider ()
@property (nonatomic, strong) id<UADSPerformanceLogger>performanceLogger;
@property (nonatomic, strong) UADSPerformanceMeasurer *performanceMeasurer;
@end

@implementation UADSServiceProvider
_uads_custom_singleton_imp(UADSServiceProvider, ^{
    return [self new];
})

- (instancetype)init {
    SUPER_INIT
    self.configurationStorage = [UADSConfigurationCRUDBase new];
    self.requestFactory = [USRVWebRequestFactory new];
    return self;
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)hbTokenReader {
    @synchronized (self) {
        if (!_hbTokenReader) {
            UADSHeaderBiddingTokenReaderBuilder *tokenReaderBuilder = self.tokenBuilder;
            tokenReaderBuilder.metricsSender = self.metricSender;
            _hbTokenReader = tokenReaderBuilder.defaultReader;
        }
    }
    return _hbTokenReader;
}

- (id<UADSWebViewEventSender>)webViewEventSender {
    if (_webViewEventSender) {
        return _webViewEventSender;
    }
    return [UADSWebViewEventSenderBase new];
}

- (id<UADSHeaderBiddingAsyncTokenReader>)nativeTokenGenerator {
    UADSHeaderBiddingTokenReaderBuilder *tokenReaderBuilder = self.tokenBuilder;
    tokenReaderBuilder.nativeTokenPrefix = @"";
    return tokenReaderBuilder.tokenGenerator;
}

- (UADSHeaderBiddingTokenReaderBuilder *)tokenBuilder {
    if (_tokenBuilder) {
        return _tokenBuilder;
    }
    UADSHeaderBiddingTokenReaderBuilder *tokenReaderBuilder = [UADSHeaderBiddingTokenReaderBuilder new];
    tokenReaderBuilder.privacyStorage = self.privacyStorage;
    tokenReaderBuilder.sdkConfigReader = self.configurationStorage;
    tokenReaderBuilder.tokenCRUD =  [UADSTokenStorage sharedInstance];
    return tokenReaderBuilder;
}

- (id<UADSConfigurationSaver>)configurationSaver {
    return [UADSConfigurationSaverWithTokenStorage newWithTokenCRUD: self.hbTokenReader
                                                        andOriginal: self.configurationStorage];
}

- (id<ISDKMetrics>)metricSender {
    @synchronized (self) {
        if (!_metricSender) {
            _metricSender = [UADSMetricSender newWithConfigurationReader: _configurationStorage
                                                       andRequestFactory: _requestFactory
                                                           storageReader: [USRVStorageManager getStorage: kUnityServicesStorageTypePublic]
                                                           privacyReader: self.privacyStorage];
            _metricSender = [UADSMetricSenderWithBatch decorateWithMetricSender: _metricSender
                                                        andConfigurationSubject: self.configurationStorage
                                                                      andLogger: self.logger];
        }
    }

    return _metricSender;
}

- (id<UADSPrivacyResponseSaver, UADSPrivacyResponseReader, UADSPrivacyResponseSubject>)privacyStorage {
    @synchronized (self) {
        if (!_privacyStorage) {
            _privacyStorage = [UADSPrivacyStorage new];
        }
    }
    return _privacyStorage;
}

- (id<UADSConfigurationLoader>)configurationLoaderUsing: (USRVConfiguration *)configuration retryInfoReader: (id<UADSRetryInfoReader>)retryInfoReader {
    UADSConfigurationRequestFactoryConfigBase *config = [UADSConfigurationRequestFactoryConfigBase defaultWithExperiments: configuration.experiments];
    UADSConfigurationLoaderBuilder *builder = [UADSConfigurationLoaderBuilder newWithConfig: config
                                                                       andWebRequestFactory      : self.requestFactory];

    builder.privacyStorage = self.privacyStorage;
    builder.logger = self.logger;
    builder.configurationSaver = self.configurationSaver;
    builder.currentTimeStampReader = [UADSCurrentTimestampBase new];
    builder.retryInfoReader = retryInfoReader;
    return builder.loader;
}

- (id<UADSLogger>)logger {
    @synchronized (self) {
        if (!_logger) {
            _logger = [UADSConsoleLogger newWithSystemList: @[]];
        }
    }
    return _logger;
}

- (id<UADSPerformanceLogger>)performanceLogger {
    @synchronized (self) {
        if (!_performanceLogger) {
            _performanceLogger = [UADSPerformanceLoggerBase newWithLogger: self.logger];
        }
    }

    return _performanceLogger;
}

- (UADSPerformanceMeasurer *)performanceMeasurer {
    @synchronized (self) {
        if (!_performanceMeasurer) {
            _performanceMeasurer = [UADSPerformanceMeasurer newWithTimestampReader: [UADSCurrentTimestampBase new]];
        }
    }

    return _performanceMeasurer;
}

@end
