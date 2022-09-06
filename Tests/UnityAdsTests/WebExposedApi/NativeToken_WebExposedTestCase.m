#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSDeviceReaderMock.h"
#import "SDKMetricsSenderMock.h"
#import "UADSConfigurationReaderMock.h"
#import "XCTestCase+Convenience.h"
#import "UADSPrivacyStorageMock.h"
#import "UADSServiceProvider.h"
#import "UADSApiToken.h"
#import "UADSEventSenderMock.h"

NSString *const kTokenEventName = @"TOKEN_NATIVE_DATA";
NSString *const kTokenCategoryName = @"TOKEN";

@interface NativeToken_WebExposedTestCase : XCTestCase
@property (nonatomic, strong) UADSDeviceReaderMock *readerMock;
@property (nonatomic, strong) SDKMetricsSenderMock *metricSenderMock;
@property (nonatomic, strong) UADSPrivacyStorage *privacyMock;
@property (nonatomic, strong) UADSConfigurationReaderMock *configReaderMock;
@property (nonatomic, strong) UADSEventSenderMock *eventSenderMock;
@end

@implementation NativeToken_WebExposedTestCase

- (void)setUp {
    [super setUp];
    self.readerMock = [UADSDeviceReaderMock new];
    self.readerMock.expectedInfo = @{ @"test": @"info" };
    self.metricSenderMock = [SDKMetricsSenderMock new];
    self.privacyMock = [UADSPrivacyStorage new];
    self.eventSenderMock = [UADSEventSenderMock new];
    UADSHeaderBiddingTokenReaderBuilder *builder = [UADSHeaderBiddingTokenReaderBuilder new];

    UADSServiceProvider.sharedInstance.tokenBuilder = builder;
    UADSServiceProvider.sharedInstance.metricSender = self.metricSenderMock;
    UADSServiceProvider.sharedInstance.webViewEventSender = self.eventSenderMock;
    builder.sdkConfigReader = self.configReaderMock;
    builder.privacyStorage = self.privacyMock;
    builder.tokenCRUD = [UADSTokenStorage new];
    builder.deviceInfoReader = self.readerMock;
}

- (void)tearDown {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

    UADSServiceProvider.sharedInstance.tokenBuilder = nil;
    UADSServiceProvider.sharedInstance.metricSender = nil;
    UADSServiceProvider.sharedInstance.webViewEventSender = nil;

#pragma clang diagnostic pop
}

- (void)test_token_doesnt_have_prefix {
    [UADSApiToken WebViewExposed_getNativeGeneratedToken: [USRVWebViewCallback new]];
    id<UADSWebViewEvent> lastEvent = _eventSenderMock.receivedEvents.lastObject;
    id<UADSWebViewEvent> expectedEvent = self.expectedEvent;

    XCTAssertEqualObjects(lastEvent.categoryName, expectedEvent.categoryName);
    XCTAssertEqualObjects(lastEvent.eventName, expectedEvent.eventName);
    XCTAssertEqualObjects(lastEvent.params, expectedEvent.params);
}

- (void)test_web_exposed_token_generator_doesnt_send_metrics {
    [UADSApiToken WebViewExposed_getNativeGeneratedToken: [USRVWebViewCallback new]];
    XCTAssertEqual(_metricSenderMock.callCount, 0);
}

- (UADSWebViewEventBase *)expectedEvent {
    // encoded device info: @{ @"test": @"info" };
    NSString *token = @"H4sIAAAAAAAAE6tWKkktLlGyUsrMS8tXqgUAIuq+TA8AAAA=";

    return [UADSWebViewEventBase newWithCategory: kTokenCategoryName
                                       withEvent: kTokenEventName
                                      withParams: @[token]];
}

@end
