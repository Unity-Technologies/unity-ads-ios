#import "UADSLoaderIntegrationTestsHelper.h"
#import <XCTest/XCTest.h>
#import "XCTestCase+Convenience.h"
#import "NSDictionary+JSONString.h"
#import "NSArray+Map.h"
#import "NSArray+Sort.h"
#import "UADSConfigurationPersistenceMock.h"
#import "UADSBaseURLBuilder.h"
#import "SDKMetricsSenderMock.h"
#import "NSData+GZIP.h"


@implementation UADSLoaderIntegrationTestsHelper

- (void)validateURLofRequest: (NSString *)urlString
        withExpectedHostHame: (NSString *)hostName
          andExpectedQueries: (NSDictionary *)queryAttributes {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString: urlString];
    NSURLComponents *expectedHost = [[NSURLComponents alloc] initWithString: hostName];

    NSArray *queries =  [components.queryItems uads_mapObjectsUsingBlock:^id _Nonnull (NSURLQueryItem *_Nonnull item) {
        return item.name;
    }];

    UADSBaseURLBuilderBase *urlBuilder = [UADSBaseURLBuilderBase newWithHostNameProvider: UADSConfigurationEndpointProvider.defaultProvider];
    NSURLComponents *expectedFromBuilder = [[NSURLComponents alloc] initWithString: urlBuilder.baseURL];

    queries = queries.defaultSorted;
    NSArray *expectedQueries = queryAttributes.allKeys.defaultSorted;


    XCTAssertEqualObjects(components.host, expectedHost.host ? : hostName);
    XCTAssertEqualObjects(queries, expectedQueries);
    XCTAssertEqualObjects(components.path, expectedFromBuilder.path);
}

- (void)validateURLOfRequest: (NSString *)urlString withExpectedCompressedKeys: (NSArray *)expectedKeys {
    if (expectedKeys == nil || expectedKeys.count == 0) {
        return;
    }

    NSURLComponents *components = [[NSURLComponents alloc] initWithString: urlString];
    __block NSString *compressed;

    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj.name isEqualToString: @"c"]) {
            compressed = obj.value;
            *stop = YES;
        }
    }];

    if (compressed == nil) {
        XCTFail("Request does not have compressed query item");
    }

    NSData *decoded = [[NSData alloc] initWithBase64EncodedString: compressed
                                                          options: 0];

    decoded = [decoded uads_gunzippedData];
    NSDictionary *params = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: decoded
                                                                           options: 0
                                                                             error: nil];

    for (NSString *key in expectedKeys) {
        if (params[key] == nil) {
            XCTFail("Request does not have a parameter for %@ key", key);
        }
    }
}

- (NSDictionary *)successPayload {
    return @{
        kUnityServicesConfigValueUrl: @"url",
        kUnityServicesConfigValueUAToken: @"tkn",
        kUnityServicesConfigValueStateID: @"sid",
    };
}

- (NSDictionary *)successPayloadPrivacy {
    return @{
        @"pas": @(true)
    };
}

- (NSDictionary *)successPayloadMissedData {
    return @{
        kUnityServicesConfigValueUrl: @"url",
    };
}

- (NSDictionary *)legacyFlowQueries {
    return @{
        @"gameId": @"gameIDvalue",
        @"sdkVersionName": @"sdkVersionNameValue",
        @"ts": @"tsValue",
        @"sdkVersion": @"sdkVersion"
    };
}

@end
