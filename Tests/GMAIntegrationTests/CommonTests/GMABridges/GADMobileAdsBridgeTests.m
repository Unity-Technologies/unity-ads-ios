#import <XCTest/XCTest.h>
#import "GADMobileAdsBridge.h"

@interface GADMobileAdsBridgeTests : XCTestCase

@end

@implementation GADMobileAdsBridgeTests

- (void)test_the_class_exists {
    XCTAssertTrue([GADMobileAdsBridge exists]);
}

- (void)test_shared_instance_is_not_null {
    XCTAssertNotNil(GADMobileAdsBridge.sharedInstance.proxyObject);
}

- (void)test_exists_returns_true {
    XCTAssertTrue([GADMobileAdsBridge exists]);
}

@end
