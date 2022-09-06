#import <XCTest/XCTest.h>
#import "UADSWebRequestSwiftAdapterWithFallback.h"
#import "WebRequestFactoryMock.h"
#import "WebRequestMock.h"
#import "SDKMetricsSenderMock.h"

@interface UADSWebRequestSwiftAdapterWithFallbackTests : XCTestCase
@property (nonatomic, strong) WebRequestMock *original;
@property (nonatomic, strong) WebRequestFactoryMock *fallback;
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;

@end

@implementation UADSWebRequestSwiftAdapterWithFallbackTests

- (void)setUp {
    _original = [WebRequestMock new];
    _fallback = [WebRequestFactoryMock new];
    _metricsMock = nil;
}

- (void)test_not_fallback_to_objc_if_swift_return_400 {
    UADSWebRequestSwiftAdapterWithFallback *sut = [self sutWithMetrics: true];

    _original.error = [NSError errorWithDomain: UADSSwiftErrorDomain
                                          code: 400
                                      userInfo: nil];
    _original.isResponseCodeInvalid = true;

    [sut makeRequest];

    XCTAssertEqual(_fallback.createdRequests.count, 0);
    XCTAssertEqual(_metricsMock.sentMetrics.count, 0);
}

- (void)test_fallbacks_to_objc_on_not_swift_domain_error {
    UADSWebRequestSwiftAdapterWithFallback *sut = [self sutWithMetrics: true];

    _original.error = [NSError errorWithDomain: @"some_other_domain"
                                          code: 400
                                      userInfo: nil];
    _original.isResponseCodeInvalid = true;

    [sut makeRequest];

    XCTAssertEqual(_fallback.createdRequests.count, 1);
    XCTAssertEqual(_metricsMock.sentMetrics.count, 1);
}

- (void)test_fallbacks_to_objc_if_swift_throws {
    UADSWebRequestSwiftAdapterWithFallback *sut = [self sutWithMetrics: false];

    _original.throwExceptionOnMakeRequest = true;

    [sut makeRequest];

    XCTAssertEqual(_fallback.createdRequests.count, 1);
}

- (void)test_does_not_fallback_to_objc_if_swift_succeeds {
    UADSWebRequestSwiftAdapterWithFallback *sut = [self sutWithMetrics: false];

    _original.expectedData = [NSData data];

    [sut makeRequest];

    XCTAssertEqual(_fallback.createdRequests.count, 0);
}

- (UADSWebRequestSwiftAdapterWithFallback *)sutWithMetrics: (BOOL)metrics {
    if (metrics) {
        _metricsMock = [SDKMetricsSenderMock new];
    }

    return [UADSWebRequestSwiftAdapterWithFallback newWithOriginal: _original
                                                   fallbackFactory: _fallback
                                                      metricSender: _metricsMock];
}

@end
