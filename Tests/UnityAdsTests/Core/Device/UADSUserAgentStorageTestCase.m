#import <XCTest/XCTest.h>
#import "UADSUserAgentStorage.h"
#import "USRVPreferences.h"
#import "WKWebView+UserAgent.h"
#import "USRVDevice.h"

static NSString *const kUADSLastKnownSystemVersionMock = @"System";
static NSString *const kUADSLastKnownUserAgentMock = @"Agent";

@interface UADSUserAgentStorageTestCase : XCTestCase

@end

@implementation UADSUserAgentStorageTestCase

- (void)setUp {
    [USRVPreferences removeKey: kUADSLastKnownSystemVersionKey];
    [USRVPreferences removeKey: kUADSLastKnownUserAgent];
}

- (void)test_generates_new_agent {
    XCTAssertEqualObjects(self.sut.userAgent, [self getCurrentUserAgent]);
}

- (void)test_returns_saved_agent {
    [self saveCurrentIOSVersion];
    [self saveMockUserAgent];
    XCTAssertEqualObjects(self.sut.userAgent, kUADSLastKnownUserAgentMock);
}

- (void)test_updates_new_agent_when_ios_different {
    [self saveMockIOSVersion];
    [self saveMockUserAgent];
    XCTAssertEqualObjects(self.sut.userAgent, [self getCurrentUserAgent]);
}

- (UADSUserAgentStorage *)sut {
    return [UADSUserAgentStorage new];
}

- (void)saveMockUserAgent {
    [USRVPreferences setString: kUADSLastKnownUserAgentMock
                        forKey: kUADSLastKnownUserAgent];
}

- (void)saveMockIOSVersion {
    [self saveIOSVersion: kUADSLastKnownSystemVersionMock];
}

- (void)saveCurrentIOSVersion {
    [self saveIOSVersion: [USRVDevice getOsVersion]];
}

- (void)saveIOSVersion: (NSString *)version {
    [USRVPreferences setString: version
                        forKey: kUADSLastKnownSystemVersionKey];
}

- (NSString *)getCurrentUserAgent {
    return [WKWebView uads_getUserAgentSync];
}

@end
