#import "UADSServiceProvider.h"
#import "UADSTools.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSConfigurationSaverWithTokenStorage.h"
#import "UADSMetricSenderWithBatch.h"
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
    return UADSHeaderBiddingTokenReaderBuilder.sharedInstance.defaultReader;
}

- (id<UADSConfigurationSaver>)configurationSaver {
    return [UADSConfigurationSaverWithTokenStorage newWithTokenCRUD: self.hbTokenReader
                                                        andOriginal: self.configurationStorage];
}

- (id<ISDKMetrics>)metricSender {
    @synchronized (self) {
        if (!_metricSender) {
            _metricSender = [UADSMetricSender newWithConfigurationReader: _configurationStorage
                                                       andRequestFactory: _requestFactory];
            _metricSender = [UADSMetricSenderWithBatch decorateWithMetricSender: _metricSender
                                                        andConfigurationSubject: _configurationStorage];
        }
    }

    return _metricSender;
}

@end
