#import <XCTest/XCTest.h>
#import "UADSLoadModule.h"
#import "USRVSdkProperties.h"
#import "UADSLoadBridge.h"
#import "USRVInitializationNotificationCenter.h"

@interface UADSLoadBridgeMock : NSObject <UADSLoadBridgeProtocol>
@property(nonatomic, strong) NSMutableArray<NSDictionary *> *loadPlacementCallLog;
@property(nonatomic, copy) void (^loadPlacementsBlock)(NSDictionary<NSString *, NSNumber *> *);

-(void)loadPlacements:(NSDictionary<NSString *, NSNumber *> *)placements;
@end

@implementation UADSLoadBridgeMock

-(instancetype)init {
    self = [super init];
    if (self) {
        self.loadPlacementCallLog = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)loadPlacements:(NSDictionary<NSString *, NSNumber *> *)placements {
    [self.loadPlacementCallLog addObject:placements];
    if (_loadPlacementsBlock) {
        _loadPlacementsBlock(placements);
    }
}

@end

@interface UADSLoadModule (Test)

-(instancetype)initWithBridge:(NSObject <UADSLoadBridgeProtocol> *)bridge initializationNotificationCenter:(NSObject <USRVInitializationNotificationCenterProtocol> *)initializeNotificationCenter;

@end

@interface UADSLoadModuleTests : XCTestCase

@property(nonatomic, strong) UADSLoadBridgeMock *loadBridgeTest;
@property(nonatomic, strong) USRVInitializationNotificationCenter *initializationNotificationCenterTest;
@property(nonatomic, strong) UADSLoadModule *loadModule;

@end

@implementation UADSLoadModuleTests

-(void)setUp {
    [super setUp];
    self.loadBridgeTest = [[UADSLoadBridgeMock alloc] init];
    self.initializationNotificationCenterTest = [[USRVInitializationNotificationCenter alloc] init];
    self.loadModule = [[UADSLoadModule alloc] initWithBridge:self.loadBridgeTest initializationNotificationCenter:self.initializationNotificationCenterTest];
}

-(void)testLoadAfterInitialized {
    [USRVSdkProperties setInitialized:YES];
    [self.loadModule load:@"test"];
    XCTAssertEqual(1, self.loadBridgeTest.loadPlacementCallLog.count);
    XCTAssertEqualObjects(@{@"test": @1}, self.loadBridgeTest.loadPlacementCallLog.firstObject);
}

-(void)testLoadWithNilPlacement {
    [USRVSdkProperties setInitialized:YES];
    [self.loadModule load:nil];
    // call log should be empty
    XCTAssertEqual(0, self.loadBridgeTest.loadPlacementCallLog.count);
}

-(void)testLoadBeforeInitialized {
    [USRVSdkProperties setInitialized:NO];
    [self.loadModule load:@"test"];
    [self.loadModule load:@"test2"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testLoadBeforeInitialized"];
    self.loadBridgeTest.loadPlacementsBlock = ^(NSDictionary *placements) {
        [expectation fulfill];
    };
    [self.initializationNotificationCenterTest triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(1, self.loadBridgeTest.loadPlacementCallLog.count);
    NSDictionary *expected = @{@"test":@1, @"test2":@1};
    XCTAssertEqualObjects(expected, self.loadBridgeTest.loadPlacementCallLog.firstObject);
    [USRVSdkProperties setInitialized:YES];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"testLoadBeforeInitialized2"];
    self.loadBridgeTest.loadPlacementsBlock = ^(NSDictionary<NSString *, NSNumber *> *placements) {
        [expectation2 fulfill];
    };
    [self.loadModule load:@"test3"];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(2, self.loadBridgeTest.loadPlacementCallLog.count);
    XCTAssertEqualObjects(@{@"test3":@1}, [self.loadBridgeTest.loadPlacementCallLog objectAtIndex:1]);
}

@end
