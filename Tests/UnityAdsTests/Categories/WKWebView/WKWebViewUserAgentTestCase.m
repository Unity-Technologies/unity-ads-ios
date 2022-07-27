#import <XCTest/XCTest.h>
#import "WKWebView+UserAgent.h"

@interface WKWebViewUserAgentTestCase : XCTestCase

@end

@implementation WKWebViewUserAgentTestCase

- (void)test_returns_web_view_agent_string {
    XCTAssertNotNil([WKWebView uads_getUserAgentSync]);
}

@end
