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
    
    if ([category isEqualToString:@"ADUNIT"]) {
        [eventArray addObject:eventId];
    }
    
    if (eventId && [eventId isEqualToString:@"VIEW_CONTROLLER_DID_DISAPPEAR"]) {
        if (self.expectation) {
           [self.expectation fulfill];
            self.expectation = nil;
        }
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

- (void)testSetViews {
    UADSViewController *viewController = [[UADSViewController alloc] init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:true completion:nil];
    
    NSArray *views = @[@"videoplayer"];
    
    [viewController setViews:views];
    
    XCTAssertTrue([[[viewController currentViews] objectAtIndex:0] isEqualToString:@"videoplayer"], @"First view should be 'videoplayer'");
    
    XCTAssertNotNil(viewController.videoView, @"Video view should not be nil");
    
    XCTAssertNotNil(viewController.videoPlayer, @"Video player should not be nil");
    
    views = @[@"webview"];
    
    [viewController setViews:views];
    
    XCTAssertTrue([[[viewController currentViews] objectAtIndex:0] isEqualToString:@"webview"], @"First view should be 'webview'");
    
    XCTAssertNil(viewController.videoView, @"Video view should be nil");
    
    XCTAssertNil(viewController.videoPlayer, @"Video player should be nil");
    
    [viewController dismissViewControllerAnimated:true completion:nil];
}

- (void)testInitWithViews {
    XCTestExpectation *presentExpectation = [self expectationWithDescription:@"initWithViewsExpectation"];
    MockWebViewAppForViewControllerTests *mockApp = (MockWebViewAppForViewControllerTests *)[UADSWebViewApp getCurrentApp];
    NSArray *views = @[@"videoplayer", @"webview"];

    UADSViewController *adUnitViewController = [[UADSViewController alloc] initWithViews:views supportedOrientations:@(24) statusBarHidden:YES shouldAutorotate:YES];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:adUnitViewController animated:true completion:^{
        [presentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
    XCTAssertTrue([adUnitViewController shouldAutorotate], @"Autorotation should be set to true");
    XCTAssertTrue([adUnitViewController prefersStatusBarHidden], @"prefersStatusBarHidden should be true");
    XCTAssertEqual(24, [adUnitViewController supportedInterfaceOrientations], @"supportedInterfaceOrientations should equal to 24");


    XCTAssertTrue([[[adUnitViewController currentViews] objectAtIndex:0] isEqualToString:@"videoplayer"], @"First view should be 'videoplayer'");
    XCTAssertTrue([[[adUnitViewController currentViews] objectAtIndex:1] isEqualToString:@"webview"], @"Second view should be 'webview'");
    
    XCTestExpectation *dismissExpectation = [self expectationWithDescription:@"dismissExpectation"];
    mockApp.expectation = dismissExpectation;
    
    [adUnitViewController dismissViewControllerAnimated:true completion:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
    
    
    XCTAssertEqual([eventArray count], 5, @"Counted events should be 5");
    
    XCTAssertTrue([@"VIEW_CONTROLLER_DID_LOAD" isEqualToString:eventArray[0]], @"First event should be VIEW_CONTROLLER_DID_LOAD");
    XCTAssertTrue([@"VIEW_CONTROLLER_INIT" isEqualToString:eventArray[1]], @"Second event should be VIEW_CONTROLLER_INIT");

    XCTAssertTrue([@"VIEW_CONTROLLER_DID_APPEAR" isEqualToString:eventArray[2]], @"Third event should be VIEW_CONTROLLER_DID_APPEAR");
    XCTAssertTrue([@"VIEW_CONTROLLER_WILL_DISAPPEAR" isEqualToString:eventArray[3]], @"Fourth event should be VIEW_CONTROLLER_WILL_DISAPPEAR");
    XCTAssertTrue([@"VIEW_CONTROLLER_DID_DISAPPEAR" isEqualToString:eventArray[4]], @"Fifth event should be VIEW_CONTROLLER_DID_DISAPPEAR");

}

@end
