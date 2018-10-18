//
//  UnityAdsExampleUITests.m
//  UnityAdsExampleUITests
//
//  Created by Brandon Zarzoza on 5/18/16.
//
//
#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "USRVConfiguration.h"
#import "USRVClientProperties.h"
#import "USRVSdkProperties.h"
#import "USRVInitialize.h"
#import "UADSHybridTest.h"
#import "USRVWebViewApp.h"
#import "UnityAds.h"

@interface MockHybridTestAppConfiguration : USRVConfiguration
@end

@implementation MockHybridTestAppConfiguration
- (NSArray<NSString*>*)getWebAppApiClassList {
    NSMutableArray *apiList = [[NSMutableArray alloc] initWithArray:[super getWebAppApiClassList]];
    [apiList addObject:@"UADSHybridTest"];
    return apiList;
}
@end

@interface UnityAdsExampleUITests : XCTestCase
@end

@implementation UnityAdsExampleUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    //[[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWebViewHybridSuite {
    [USRVClientProperties setGameId:@"14850"];
    [USRVSdkProperties setTestMode:YES];
    [UnityAds setDebugMode:YES];
    MockHybridTestAppConfiguration *configuration = [[MockHybridTestAppConfiguration alloc] init];
    [USRVSdkProperties setConfigUrl:[USRVSdkProperties getDefaultConfigUrl:@"test"]];
    [USRVInitialize initialize:configuration];
    
    // Get a reference to the webview to put it on the screen - fixes an issue where offscreen webviews are throttled to 1 request per second
    NSPredicate *webViewCreatedPredicate = [NSPredicate predicateWithFormat:@"getCurrentApp != nil"];
    
    XCTestExpectation *expectation = [self expectationForPredicate:webViewCreatedPredicate evaluatedWithObject:[USRVWebViewApp class] handler:nil];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"web view exists");
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:[USRVWebViewApp getCurrentApp].webView];
    }];
    
    NSPredicate *finishedPredicate = [NSPredicate predicateWithFormat: @"didFinish == YES"];
    expectation = [self expectationForPredicate:finishedPredicate evaluatedWithObject:[UADSHybridTest class] handler:nil];
    [self waitForExpectationsWithTimeout:300 handler:nil];
    
    XCTAssertTrue([UADSHybridTest getFailures] == 0, "Failures should be 0");
}

@end
