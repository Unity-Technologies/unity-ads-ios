#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface MockWebViewAppForViewControllerTests : UADSWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@end

NSMutableArray<NSString *> *eventArray;

@implementation MockWebViewAppForViewControllerTests


- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... {
    if (!eventArray) {
        eventArray = [[NSMutableArray alloc] init];
    }
    [eventArray addObject:eventId];
    
    if (eventId && [eventId isEqualToString:@"VIEW_CONTROLLER_DID_DISAPPEAR"]) {
        [self.expectation fulfill];
        return true;
        
    }
    return true;
}

- (BOOL)invokeCallback:(UADSInvocation *)invocation {
    return true;
}
@end

@interface ViewControllerTest : XCTestCase

@end

@implementation ViewControllerTest

- (void)setUp {
    MockWebViewAppForViewControllerTests *webApp = [[MockWebViewAppForViewControllerTests alloc] init];
    [UADSWebViewApp setCurrentApp:webApp];
    
    eventArray = nil;
}

- (void)tearDown {
    
}

- (void)testLifecycleEvents{
    XCTestExpectation *expectation = [self expectationWithDescription:@"downloadFinishExpectation"];
    MockWebViewAppForViewControllerTests *mockApp = (MockWebViewAppForViewControllerTests *)[UADSWebViewApp getCurrentApp];

    UADSViewController *viewController = [[UADSViewController alloc] init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:true completion:nil];
    [viewController dismissViewControllerAnimated:true completion:nil];

    
    [mockApp setExpectation:expectation];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertEqual([eventArray count], 4, @"Counted events should be 4");
    
    XCTAssertTrue([@"VIEW_CONTROLLER_DID_LOAD" isEqualToString:eventArray[0]], @"First event should be VIEW_CONTROLLER_DID_LOAD");
    XCTAssertTrue([@"VIEW_CONTROLLER_DID_APPEAR" isEqualToString:eventArray[1]], @"Second event should be VIEW_CONTROLLER_DID_APPEAR");
    XCTAssertTrue([@"VIEW_CONTROLLER_WILL_DISAPPEAR" isEqualToString:eventArray[2]], @"Third event should be VIEW_CONTROLLER_WILL_DISAPPEAR");
    XCTAssertTrue([@"VIEW_CONTROLLER_DID_DISAPPEAR" isEqualToString:eventArray[3]], @"Fourth event should be VIEW_CONTROLLER_DID_DISAPPEAR");
}
@end
