#import <XCTest/XCTest.h>
#import "GMABaseAdDelegateProxyTests.h"
#import "GMATestCommonConstants.h"
#import "GMABannerViewDelegateProxy.h"
#import "GMABannerWebViewEvent.h"
#import "GMALoaderBase.h"

@interface GMABannerViewDelegateProxyTests : GMABaseAdDelegateProxyTests
@end

@implementation GMABannerViewDelegateProxyTests

- (void)test_calls_success_completion_block_on_did_receive_ad {
    XCTestExpectation *exp = [self expectationWithDescription:@"load"];
    id successHandler = ^(id _Nullable obj) {
        XCTAssertNotNil(obj);
        [exp fulfill];
    };

    id errorHandler = ^(id<UADSError> _Nonnull error) {
        XCTFail(@"Should not call errorHandler");
        [exp fulfill];
    };

    UADSAnyCompletion *anyCompletion = [UADSAnyCompletion newWithSuccess: successHandler
                                                                andError: errorHandler];
    
    GMABannerViewDelegateProxy *delegateToTest = [self defaultProxyToTestWithCompletion:anyCompletion];
    [delegateToTest bannerViewDidReceiveAd:self.fakeAdObject];
    [self waitForExpectations:@[exp] timeout: 1.0];
}

- (void)test_calls_error_completion_block_on_failure {
    XCTestExpectation *exp = [self expectationWithDescription:@"load"];
    NSError *fakeError = [[NSError alloc] initWithDomain: @"domain "
                                                    code: 100
                                                userInfo: nil];
    id successHandler = ^(id _Nullable obj) {
        XCTFail(@"Should not call successHandler");
        [exp fulfill];
    };

    id errorHandler = ^(id<UADSError> _Nonnull error) {
        XCTAssertEqualObjects(error.errorDomain, kGMAEventName);
        XCTAssertEqual(error.errorCode.intValue, fakeError.code);
        [exp fulfill];
    };

    UADSAnyCompletion *anyCompletion = [UADSAnyCompletion newWithSuccess: successHandler
                                                                andError: errorHandler];
    
    GMABannerViewDelegateProxy *delegateToTest = [self defaultProxyToTestWithCompletion:anyCompletion];
    [delegateToTest bannerView:self.fakeAdObject didFailToReceiveAdWithError:fakeError];
    [self waitForExpectations:@[exp] timeout: 1.0];
}

- (void)test_sends_impression_and_click_events {

    GMABannerViewDelegateProxy *delegateToTest = [self defaultProxyToTestWithCompletion: [UADSAnyCompletion new]];
    [delegateToTest bannerViewDidRecordImpression: self.fakeAdObject];
    [delegateToTest bannerViewDidRecordClick: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMABannerWebViewEvent newBannerImpressionWithMeta:meta],
        [GMABannerWebViewEvent newBannerClickedWithMeta:meta]
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (GMABannerViewDelegateProxy *)defaultProxyToTestWithCompletion:(UADSLoadAdCompletion *)completion {
    return [self.delegatesFactory bannerDelegate: self.defaultMeta
                                   andCompletion: completion];
}

- (GMAAdMetaData *)defaultMeta {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.bannerAdId = kGMABannerAdId;
    meta.placementID = kFakePlacementID;
    meta.queryID = kGMAQueryID;
    meta.type = GADQueryInfoAdTypeBanner;
    meta.beforeLoad = ^(GADBaseAd *_Nullable ad) {};
    return meta;
}

- (NSArray *)expectedParams {
    return @[kGMABannerAdId];
}


@end
