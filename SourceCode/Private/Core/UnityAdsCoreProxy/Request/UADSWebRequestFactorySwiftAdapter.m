#import "UADSWebRequestFactorySwiftAdapter.h"
#import "UADSWebRequestSwiftAdapter.h"
#import "UADSWebRequestSwiftAdapterWithFallback.h"
#import "UADSCommonNetworkProxy.h"
@interface UADSWebRequestFactorySwiftAdapter ()
@property (nonatomic, strong) id<ISDKMetrics> metricSender;
@property (nonatomic, strong) UADSCommonNetworkProxy* networkLayer;
@end

@implementation UADSWebRequestFactorySwiftAdapter

+ (instancetype)newWithMetricSender: (id<ISDKMetrics>)metricSender
                         andNetworkLayer: (UADSCommonNetworkProxy *)networkLayer {
    UADSWebRequestFactorySwiftAdapter *factory = [UADSWebRequestFactorySwiftAdapter new];

    factory.metricSender = metricSender;
    factory.networkLayer = networkLayer;
    return factory;
}

- (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    UADSWebRequestSwiftAdapter *swiftRequest = [[UADSWebRequestSwiftAdapter alloc] initWithUrl: url
                                                                                   requestType: requestType
                                                                                       headers: headers
                                                                                connectTimeout: connectTimeout];
    [swiftRequest setNativeNetworkBuilder: _networkLayer];
    UADSWebRequestSwiftAdapterWithFallback *requestWithFallback = [UADSWebRequestSwiftAdapterWithFallback newWithOriginal: swiftRequest
                                                                                                             metricSender: _metricSender];

    return requestWithFallback;
}

@end
