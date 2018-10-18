#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"


@interface MockWebViewAppForAppSheetTests : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *presentException;
@end

@implementation MockWebViewAppForAppSheetTests

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... {
    if (eventId && [eventId isEqualToString:@"OPENED"] && category && [category isEqualToString:@"APPSHEET"]) {
        [self.presentException fulfill];
        
    }
    return true;
}

- (BOOL)invokeCallback:(USRVInvocation *)invocation {
    return true;
}

@end



@interface AppSheetTests : XCTestCase


@end

@implementation AppSheetTests

USRVAppSheet *appSheet = nil;

- (void)setUp {
    MockWebViewAppForAppSheetTests *webApp = [[MockWebViewAppForAppSheetTests alloc] init];
    [USRVWebViewApp setCurrentApp:webApp];
    
    appSheet = [USRVAppSheet instance];
    [super setUp];
}

- (void)tearDown {
    [appSheet destroyAppSheet];
    [super tearDown];
}

- (void)testSetPrepareTimeout {
    [appSheet setPrepareTimeoutInSeconds:17];
    
    XCTAssertEqual(17, appSheet.prepareTimeoutInSeconds, @"New timeout should be equal to 17 seconds");
}

- (void)testPrepare {
    if ([USRVDevice isSimulator]) {
        NSLog(@"--- IGNORED IN SIMULATOR ---");
        return;
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"prepareAppSheet"];
    
    NSDictionary *parameters = @{ @"id" : @453467175 };
    
    [appSheet prepareAppSheet:parameters prepareTimeoutInSeconds:5 completionBlock:^(BOOL result, NSString * _Nullable error) {
        XCTAssertTrue(true, "Should be prepared");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];

}

- (void)testPrepareCalledTwiceWithSameId {
    if ([USRVDevice isSimulator]) {
        NSLog(@"--- IGNORED IN SIMULATOR ---");
        return;
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"prepareAppSheet"];
    
    NSDictionary *parameters = @{ @"id" : @453467175 };
    
    [appSheet prepareAppSheet:parameters prepareTimeoutInSeconds:5 completionBlock:^(BOOL result, NSString * _Nullable error) {
        
    }];
    
    [appSheet prepareAppSheet:parameters prepareTimeoutInSeconds:5 completionBlock:^(BOOL result, NSString * _Nullable error) {
        XCTAssertEqual(false, result, @"Result should be false");
        XCTAssertTrue([error isEqualToString:@"ALREADY_PREPARING"], @"Error message should equal to ALREADY_PREPARING");

        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];
    
}

- (void)testPrepareCalledTwiceWithDifferentIds {
    if ([USRVDevice isSimulator]) {
        NSLog(@"--- IGNORED IN SIMULATOR ---");
        return;
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"prepareAppSheet"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"prepareAppSheet2"];

    
    NSDictionary *parameters = @{ @"id" : @453467175 };
    NSDictionary *parameters2 = @{ @"id" : @4534671763 };

    
    [appSheet prepareAppSheet:parameters prepareTimeoutInSeconds:5 completionBlock:^(BOOL result, NSString * _Nullable error) {
        XCTAssertEqual(true, result, @"Should be prepared");
        [expectation fulfill];
    }];
    
    [appSheet prepareAppSheet:parameters2 prepareTimeoutInSeconds:5 completionBlock:^(BOOL result, NSString * _Nullable error) {
        XCTAssertEqual(false, result, @"Result should be false");
        [expectation2 fulfill];

    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];
}

- (void)testPresentAppSheetNotPrepared {
    NSDictionary *parameters = @{ @"id" : @55555555 };
    
    [appSheet presentAppSheet:parameters animated:true completionBlock:^(BOOL result, NSString * _Nullable error) {
        XCTAssertFalse(result, @"Error should be returned");
        XCTAssertTrue([error isEqualToString:@"APPSHEET_NOT_FOUND"], "Error message should equal to APPSHEET_NOT_FOUND");

    }];
}

- (void)testPresent {
    if ([USRVDevice isSimulator]) {
        NSLog(@"--- IGNORED IN SIMULATOR ---");
        return;
    }
    
    NSDictionary *parameters = @{ @"id" : @453467175 };
    
    UADSViewController *viewController = [[UADSViewController alloc] init];
    
    XCTestExpectation *viewControllerExpectation = [self expectationWithDescription:@"presentViewController"];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:true completion:^{
        [viewControllerExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];
    
    [UADSApiAdUnit setAdUnit:viewController];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"presentAppSheetPrepare"];
    [appSheet prepareAppSheet:parameters prepareTimeoutInSeconds:5 completionBlock:^(BOOL result, NSString * _Nullable error) {
        [expectation fulfill];
        XCTAssertTrue(true, "Should be prepared");
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];
    
    [appSheet presentAppSheet:parameters animated:true completionBlock:^(BOOL result, NSString * _Nullable error) {
    }];
    
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"presentAppSheetEventExpectation"];
    MockWebViewAppForAppSheetTests *mockApp = (MockWebViewAppForAppSheetTests *)[USRVWebViewApp getCurrentApp];
    [mockApp setPresentException:expectation2];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];
    
    XCTestExpectation *appsheetDismissExpectation = [self expectationWithDescription:@"appSheetDismissViewController"];
    [viewController dismissViewControllerAnimated:false completion:^{
        [appsheetDismissExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];

    XCTestExpectation *viewControllerDismissExpectation = [self expectationWithDescription:@"dismissViewController"];
    [viewController dismissViewControllerAnimated:false completion:^{
        [viewControllerDismissExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertTrue(true, "Didn't timeout");
    }];
}

// TODO: unstable test
//- (void)testPresentLandscape {
//   [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"presentAppSheet"];
//    
//    NSDictionary *parameters = @{ @"id" : @453467175 };
//    
//    [appSheet prepareAppSheet:parameters completionBlock:^(BOOL result, NSString * _Nullable error) {
//        XCTAssertTrue(true, "Should be prepared");
//        [expectation fulfill];
//    }];
//    
//    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
//        XCTAssertTrue(true, "Didn't timeout");
//    }];
//    
//    UADSViewController *viewController = [[UADSViewController alloc] init];
//    
//    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
//    while (root.presentedViewController) {
//        root = root.presentedViewController;
//    }
//    
//    [root presentViewController:viewController animated:false completion:^{
//        [appSheet presentAppSheet:parameters animated:true completionBlock:^(BOOL result, NSString * _Nullable error) {
//            
//        }];
//    }];
//
//    XCTestExpectation *expectation2 = [self expectationWithDescription:@"presentAppSheetEventExpectation"];
//    MockWebViewAppForAppSheetTests *mockApp = (MockWebViewAppForAppSheetTests *)[USRVWebViewApp getCurrentApp];
//    [mockApp setPresentException:expectation2];
//    
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        XCTAssertTrue(true, "Didn't timeout");
//    }];
//    
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
//
//}

@end
