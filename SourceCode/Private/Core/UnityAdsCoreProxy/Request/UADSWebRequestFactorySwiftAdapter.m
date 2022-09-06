#import "UADSWebRequestFactorySwiftAdapter.h"
#import "UADSWebRequestSwiftAdapter.h"
#import "UADSWebRequestSwiftAdapterWithFallback.h"

@interface UADSWebRequestFactorySwiftAdapter ()
@property (nonatomic, strong) id<ISDKMetrics> metricSender;
@end

@implementation UADSWebRequestFactorySwiftAdapter

+ (instancetype)newWithMetricSender: (id<ISDKMetrics>)metricSender {
    UADSWebRequestFactorySwiftAdapter *factory = [UADSWebRequestFactorySwiftAdapter new];

    factory.metricSender = metricSender;
    return factory;
}

- (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    UADSWebRequestSwiftAdapter *swiftRequest = [[UADSWebRequestSwiftAdapter alloc] initWithUrl: url
                                                                                   requestType: requestType
                                                                                       headers: headers
                                                                                connectTimeout: connectTimeout];

    UADSWebRequestSwiftAdapterWithFallback *requestWithFallback = [UADSWebRequestSwiftAdapterWithFallback newWithOriginal: swiftRequest
                                                                                                             metricSender: _metricSender];

    return requestWithFallback;
}

@end
