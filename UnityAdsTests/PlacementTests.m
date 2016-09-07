#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface PlacementTests : XCTestCase
@end

@implementation PlacementTests


- (void)setUp {
    [super setUp];
    [UADSPlacement reset];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testReset {
    [UADSPlacement setDefaultPlacement:@"testPlacement"];
    [UADSPlacement reset];
    
    XCTAssertNil([UADSPlacement getDefaultPlacement], "Default placement should be NULL");
    XCTAssertFalse([UADSPlacement isReady:@"testPlacement"], "Placement 'testPlacement' should not be ready");
    XCTAssertEqual([UADSPlacement getPlacementState], kUnityAdsPlacementStateNotAvailable);
    XCTAssertEqual([UADSPlacement getPlacementState:@"testPlacement"], kUnityAdsPlacementStateNotAvailable);
}

- (void)testSetDefaultPlacement {
    NSString *testPlacement = @"testPlacement";
    [UADSPlacement setDefaultPlacement:testPlacement];
    XCTAssertEqual([UADSPlacement getDefaultPlacement], testPlacement);
}

- (void)testSetPlacementState {
    NSString *testPlacement = @"testPlacement";
    NSString *testPlacement2 = @"testPlacement2";
    
    [UADSPlacement setPlacementState:testPlacement placementState:@"NO_FILL"];
    XCTAssertEqual([UADSPlacement getPlacementState:testPlacement], kUnityAdsPlacementStateNoFill);
    [UADSPlacement setPlacementState:testPlacement2  placementState:@"NOT_AVAILABLE"];
    XCTAssertEqual([UADSPlacement getPlacementState:testPlacement2], kUnityAdsPlacementStateNotAvailable);
    [UADSPlacement setPlacementState:testPlacement placementState:@"READY"];
    XCTAssertEqual([UADSPlacement getPlacementState:testPlacement], kUnityAdsPlacementStateReady);
    [UADSPlacement setPlacementState:testPlacement2 placementState:@"DISABLED"];
    XCTAssertEqual([UADSPlacement getPlacementState:testPlacement2], kUnityAdsPlacementStateDisabled);
    [UADSPlacement setPlacementState:testPlacement placementState:@"WAITING"];
    XCTAssertEqual([UADSPlacement getPlacementState:testPlacement], kUnityAdsPlacementStateWaiting);
}

- (void)testIsPlacementReady {
    NSString *testPlacement = @"testPlacement";
    
    XCTAssertFalse([UADSPlacement isReady:testPlacement]);
    [UADSPlacement setPlacementState:testPlacement placementState:@"DISABLED"];
    XCTAssertFalse([UADSPlacement isReady:testPlacement]);
    [UADSPlacement setPlacementState:testPlacement placementState:@"READY"];
    XCTAssertTrue([UADSPlacement isReady:testPlacement]);
    [UADSPlacement setPlacementState:testPlacement placementState:@"NO_FILL"];
    XCTAssertFalse([UADSPlacement isReady:testPlacement]);
}

- (void)testIsDefaultPlacementReady {
    NSString *defaultPlacement = @"defaultPlacement";
    
    XCTAssertFalse([UADSPlacement isReady]);
    [UADSPlacement setDefaultPlacement:defaultPlacement];
    XCTAssertFalse([UADSPlacement isReady]);
    [UADSPlacement setPlacementState:defaultPlacement placementState:@"WAITING"];
    XCTAssertFalse([UADSPlacement isReady]);
    [UADSPlacement setPlacementState:defaultPlacement placementState:@"READY"];
    XCTAssertTrue([UADSPlacement isReady]);
}

@end