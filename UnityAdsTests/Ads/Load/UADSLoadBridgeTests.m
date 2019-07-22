#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "UADSLoadBridge.h"

@interface MockWebViewAppForLoadBridgeTests : USRVWebViewApp
@property(nonatomic, copy) void (^loadPlacementsCallback)(NSString *eventId, NSString *category, NSArray *params);
@end

@implementation MockWebViewAppForLoadBridgeTests

-(BOOL)sendEvent:(NSString *)eventId category:(NSString *)category params:(NSArray *)params {
    if (eventId && [eventId isEqualToString:@"LOAD_PLACEMENTS"] && category && [category isEqualToString:@"LOAD_API"]) {
        _loadPlacementsCallback(eventId, category, params);
    }
    return true;
}

-(BOOL)invokeCallback:(USRVInvocation *)invocation {
    return true;
}

@end


@interface UADSLoadBridgeTests : XCTestCase

@end

@implementation UADSLoadBridgeTests

UADSLoadBridge *loadBridge = nil;

-(void)setUp {
    MockWebViewAppForLoadBridgeTests *webApp = [[MockWebViewAppForLoadBridgeTests alloc] init];
    [USRVWebViewApp setCurrentApp:webApp];

    loadBridge = [[UADSLoadBridge alloc] init];
}

-(void)tearDown {
    [USRVWebViewApp setCurrentApp:nil];
}

-(void)testSendLoadEvent {
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"presentAppSheetEventExpectation"];
    MockWebViewAppForLoadBridgeTests *mockApp = (MockWebViewAppForLoadBridgeTests *) [USRVWebViewApp getCurrentApp];
    mockApp.loadPlacementsCallback = ^(NSString *eventId, NSString *category, NSArray *params){
        if (params.count == 1 && [params[0] isEqual:@{@"video1":@1, @"video2":@1}]) {
            [expectation2 fulfill];
        }
    };

    [loadBridge loadPlacements:@{@"video1":@1, @"video2":@1}];

    [self waitForExpectationsWithTimeout:1 handler:^(NSError *_Nullable error) {}];
}

@end
