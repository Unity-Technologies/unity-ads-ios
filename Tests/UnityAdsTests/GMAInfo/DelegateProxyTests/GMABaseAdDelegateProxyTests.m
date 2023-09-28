#import "GMABaseAdDelegateProxyTests.h"
#import "XCTestCase+Convenience.h"
#import "GMALoaderBase.h"
#import "UADSWebViewErrorHandler.h"
#import "NSArray+Map.h"
#import "GMAWebViewEvent.h"

@implementation GMABaseAdDelegateProxyTests

- (void)setUp {
    [self resetUnityAds];
    _timerFactoryMock = [UADSTimerFactoryMock new];
    _webAppMock = [USRVWebViewAppMock new];
    [USRVWebViewApp setCurrentApp: _webAppMock];
}

- (void)tearDown {
    _webAppMock = nil;
    [USRVWebViewApp setCurrentApp: _webAppMock];
    [self resetUnityAds];
}


- (NSArray *)expectedParams {
    return @[];
}

- (id<GMADelegatesFactory>)delegatesFactory {
    id<UADSWebViewEventSender>eventSender = [UADSWebViewEventSenderBase new];

    id<UADSErrorHandler>errorHandler = [UADSWebViewErrorHandler newWithEventSender: eventSender];

    return [GMADelegatesBaseFactory newWithEventSender: eventSender
                                          errorHandler: errorHandler
                                          timerFactory: _timerFactoryMock];
}

- (void)validateExpectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents {
    NSArray *expectedEventNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (GMAWebViewEvent *_Nonnull obj) {
        return obj.eventName;
    }];

    NSArray *expectedCategoryNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (GMAWebViewEvent *_Nonnull obj) {
        return obj.categoryName;
    }];

    XCTAssertEqualObjects(_webAppMock.eventNames, expectedEventNames);
    XCTAssertEqualObjects(_webAppMock.categoryNames, expectedCategoryNames);
}

- (void)validateExpectedDefaultParamsInEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents  {
    NSArray *expectedParams = [NSArray new];

    for (id event in expectedEvents) {
        expectedParams = [expectedParams arrayByAddingObject: self.expectedParams];         // creating expected array since default params are the same
    }

    XCTAssertEqualObjects(_webAppMock.params, expectedParams);
}

- (id)fakeAdObject {
    return [NSObject new];
}

@end
