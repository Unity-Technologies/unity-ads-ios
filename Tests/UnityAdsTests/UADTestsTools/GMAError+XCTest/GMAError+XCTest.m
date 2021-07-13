#import "GMAError+XCTest.h"
#import <XCTest/XCTest.h>
#import "GMATestCommonConstants.h"

@implementation GMAError (XCTest)

- (void)testWithEventName: (NSString *)name
                expParams: (NSArray *)params {
    id<UADSWebViewEvent>event = [self convertToEvent];

    XCTAssertEqualObjects(event.eventName, name);
    XCTAssertEqualObjects(event.categoryName, kGMAEventName);
    XCTAssertEqualObjects(event.params, params);
}

@end
