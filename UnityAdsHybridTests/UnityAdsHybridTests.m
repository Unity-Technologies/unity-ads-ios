//
//  UnityAdsExampleUITests.m
//  UnityAdsExampleUITests
//
//  Created by Brandon Zarzoza on 5/18/16.
//
//
#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "UADSConfiguration.h"
#import "UADSClientProperties.h"
#import "UADSSdkProperties.h"
#import "UADSInitialize.h"
#import "UADSHybridTest.h"
#import "UADSWebViewApp.h"

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
    [UADSClientProperties setGameId:@"14850"];
    //[UADSClientProperties setDelegate:delegate];
    [UADSSdkProperties setTestMode:YES];
    [UnityAds setDebugMode:YES];
    UADSConfiguration *configuration = [[UADSConfiguration alloc] init];
    
    NSArray *classList = @[
                           @"UADSApiSdk",
                           @"UADSApiStorage",
                           @"UADSApiDeviceInfo",
                           @"UADSApiPlacement",
                           @"UADSApiCache",
                           @"UADSApiUrl",
                           @"UADSApiListener",
                           @"UADSApiAdUnit",
                           @"UADSApiVideoPlayer",
                           @"UADSApiRequest",
                           @"UADSApiAppSheet",
                           @"UADSApiUrlScheme",
                           @"UADSApiNotification",
                           @"UADSHybridTest"
                           ];
    [UADSSdkProperties setConfigUrl:[UADSSdkProperties getDefaultConfigUrl:@"test"]];
    
    [configuration setWebAppApiClassList:classList];
    [UADSInitialize initialize:configuration];
    
    // Get a reference to the webview to put it on the screen - fixes an issue where offscreen webviews are throttled to 1 request per second
    NSPredicate *webViewCreatedPredicate = [NSPredicate predicateWithFormat:@"getCurrentApp != nil"];
    
    XCTestExpectation *expectation = [self expectationForPredicate:webViewCreatedPredicate evaluatedWithObject:[UADSWebViewApp class] handler:nil];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"web view exists");
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:[UADSWebViewApp getCurrentApp].webView];
    }];
    
    NSPredicate *finishedPredicate = [NSPredicate predicateWithFormat: @"didFinish == YES"];
    expectation = [self expectationForPredicate:finishedPredicate evaluatedWithObject:[UADSHybridTest class] handler:nil];
    [self waitForExpectationsWithTimeout:300 handler:nil];
}

@end
