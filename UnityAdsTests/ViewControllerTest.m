#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface MockWebViewAppForViewControllerTests : USRVWebViewApp
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

- (BOOL)invokeCallback:(USRVInvocation *)invocation {
    return true;
}
@end

@interface ViewControllerTest : XCTestCase

@end

@implementation ViewControllerTest

- (void)setUp {
    MockWebViewAppForViewControllerTests *webApp = [[MockWebViewAppForViewControllerTests alloc] init];
    [USRVWebViewApp setCurrentApp:webApp];
    [webApp setConfiguration:[[USRVConfiguration alloc] init]];
    
    eventArray = nil;
}

- (void)tearDown {
    
}

- (void)testLifecycleEvents{
    XCTestExpectation *expectation = [self expectationWithDescription:@"downloadFinishExpectation"];
    MockWebViewAppForViewControllerTests *mockApp = (MockWebViewAppForViewControllerTests *)[USRVWebViewApp getCurrentApp];

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
    XCTestExpectation *presentExpectation = [self expectationWithDescription:@"initWithViewsExpectation"];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:true completion:^{
        [presentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];

    NSArray *views = @[@"videoplayer"];
    
    [viewController setViews:views];
    
    XCTAssertTrue([[[viewController currentViews] objectAtIndex:0] isEqualToString:@"videoplayer"], @"First view should be 'videoplayer'");
    
    XCTAssertNotNil([(UADSVideoPlayerHandler *)[viewController getViewHandler:@"videoplayer"] videoView], @"Video view should not be nil");
    
    XCTAssertNotNil([(UADSVideoPlayerHandler *)[viewController getViewHandler:@"videoplayer"] videoPlayer], @"Video player should not be nil");
    
    views = @[@"webview"];
    
    [viewController setViews:views];
    
    XCTAssertTrue([[[viewController currentViews] objectAtIndex:0] isEqualToString:@"webview"], @"First view should be 'webview'");
    
    XCTAssertNil([(UADSVideoPlayerHandler *)[viewController getViewHandler:@"videoplayer"] videoView], @"Video view should be nil");
    
    XCTAssertNil([(UADSVideoPlayerHandler *)[viewController getViewHandler:@"videoplayer"] videoPlayer], @"Video player should be nil");
    
    XCTestExpectation *dismissExpectation = [self expectationWithDescription:@"dismissExpectation"];
    [viewController dismissViewControllerAnimated:true completion:^{
        [dismissExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testInitWithViews {
    XCTestExpectation *presentExpectation = [self expectationWithDescription:@"initWithViewsExpectation"];
    MockWebViewAppForViewControllerTests *mockApp = (MockWebViewAppForViewControllerTests *)[USRVWebViewApp getCurrentApp];
    NSArray *views = @[@"videoplayer", @"webview"];

    UADSViewController *adUnitViewController = [[UADSViewController alloc] initWithViews:views supportedOrientations:@(24) statusBarHidden:YES shouldAutorotate:YES isTransparent:NO homeIndicatorAutoHidden:NO];
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

- (void)testSetTransform {
    XCTestExpectation *presentExpectation = [self expectationWithDescription:@"initExpectation"];
    MockWebViewAppForViewControllerTests *mockApp = (MockWebViewAppForViewControllerTests *)[USRVWebViewApp getCurrentApp];
    NSArray *views = @[@"videoplayer", @"webview"];
    
    UADSViewController *adUnitViewController = [[UADSViewController alloc] initWithViews:views supportedOrientations:@(24) statusBarHidden:YES shouldAutorotate:YES isTransparent:NO homeIndicatorAutoHidden:NO];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:adUnitViewController animated:true completion:^{
        [presentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
    
    [adUnitViewController setTransform:0.9];
    
    XCTestExpectation *delayExpectation  = [self expectationWithDescription:@"delayEndExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [delayExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError * _Nullable error) {
    }];
    
    NSNumber *transform = [(NSNumber *)adUnitViewController.view valueForKeyPath:@"layer.transform.rotation.z"];
    XCTAssertEqual([transform doubleValue], 0.9f, @"Expected 0.9 as transform value");
    
    XCTestExpectation *dismissExpectation = [self expectationWithDescription:@"dismissExpectation"];
    mockApp.expectation = dismissExpectation;
    
    [adUnitViewController dismissViewControllerAnimated:true completion:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testSetViewFrame {
    UIWebView *webView = NULL;
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
    
    XCTestExpectation *presentExpectation = [self expectationWithDescription:@"initExpectation"];
    MockWebViewAppForViewControllerTests *mockApp = (MockWebViewAppForViewControllerTests *)[USRVWebViewApp getCurrentApp];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    NSArray *views = @[@"videoplayer", @"webview"];
    
    UADSViewController *adUnitViewController = [[UADSViewController alloc] initWithViews:views supportedOrientations:@(24) statusBarHidden:YES shouldAutorotate:YES isTransparent:NO homeIndicatorAutoHidden:NO];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:adUnitViewController animated:true completion:^{
        [presentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
    
    [adUnitViewController setViewFrame:@"adunit" x:50 y:60 width:510 height:520];
    [adUnitViewController setViewFrame:@"videoplayer" x:110 y:120 width:130 height:140];
    [adUnitViewController setViewFrame:@"webview" x:210 y:220 width:230 height:240];

    XCTestExpectation *delayExpectation  = [self expectationWithDescription:@"delayEndExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [delayExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertEqual([adUnitViewController view].frame.origin.x, 50, "ViewController view origin x not what was expected");
    XCTAssertEqual([adUnitViewController view].frame.origin.y, 60, "ViewController view origin y not what was expected");
    XCTAssertEqual([adUnitViewController view].frame.size.width, 510, "ViewController view width not what was expected");
    XCTAssertEqual([adUnitViewController view].frame.size.height, 520, "ViewController view height not what was expected");

    XCTAssertEqual([(UADSVideoPlayerHandler *)[adUnitViewController getViewHandler:@"videoplayer"] videoView].frame.origin.x, 110, "VideoView view origin x not what was expected");
    XCTAssertEqual([(UADSVideoPlayerHandler *)[adUnitViewController getViewHandler:@"videoplayer"] videoView].frame.origin.y, 120, "VideoView view origin y not what was expected");
    XCTAssertEqual([(UADSVideoPlayerHandler *)[adUnitViewController getViewHandler:@"videoplayer"] videoView].frame.size.width, 130, "VideoView view width not what was expected");
    XCTAssertEqual([(UADSVideoPlayerHandler *)[adUnitViewController getViewHandler:@"videoplayer"] videoView].frame.size.height, 140, "VideoView view height not what was expected");

    XCTAssertEqual([[USRVWebViewApp getCurrentApp] webView].frame.origin.x, 210, "WebView view origin x not what was expected");
    XCTAssertEqual([[USRVWebViewApp getCurrentApp] webView].frame.origin.y, 220, "WebView view origin y not what was expected");
    XCTAssertEqual([[USRVWebViewApp getCurrentApp] webView].frame.size.width, 230, "WebView view width not what was expected");
    XCTAssertEqual([[USRVWebViewApp getCurrentApp] webView].frame.size.height, 240, "WebView view height not what was expected");
    
    XCTestExpectation *dismissExpectation = [self expectationWithDescription:@"dismissExpectation"];
    mockApp.expectation = dismissExpectation;
    
    [adUnitViewController dismissViewControllerAnimated:true completion:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testSetHomeIndicatorAutoHidden {
    XCTestExpectation *presentExpectation = [self expectationWithDescription:@"initWithViewsExpectation"];
    MockWebViewAppForViewControllerTests *mockApp = (MockWebViewAppForViewControllerTests *)[USRVWebViewApp getCurrentApp];
    
    UADSViewController *viewController = [[UADSViewController alloc] init];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:true completion:^{
        [presentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertFalse([viewController prefersHomeIndicatorAutoHidden], @"prefersHomeIndicaroAutoHidden should be false");
    
    [viewController setHomeIndicatorAutoHidden:YES];
    
    XCTAssertTrue([viewController prefersHomeIndicatorAutoHidden], @"prefersHomeIndicaroAutoHidden should be true");
    
    [viewController dismissViewControllerAnimated:true completion:nil];
    
    XCTestExpectation *dismissExpectation = [self expectationWithDescription:@"dismissExpectation"];
    mockApp.expectation = dismissExpectation;
    
    [viewController dismissViewControllerAnimated:true completion:nil];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
}

@end
