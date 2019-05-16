#import <XCTest/XCTest.h>
#import "UnityAds.h"
#import "UADSProperties.h"
#import "UnityAdsDelegateMock.h"

@interface UnityServices (Mock)
@end

@implementation UnityServices (Mock)

+(void)initialize:(NSString *)gameId
         delegate:(nullable id <UnityServicesDelegate>)delegate
         testMode:(BOOL)testMode {
    // do nothing
}

@end

@interface UnityAdsTests : XCTestCase
@end

@implementation UnityAdsTests

- (void)setUp {
    [super setUp];
    // reset UADSProperties object
    for (id<UnityAdsDelegate> delegate in [UADSProperties getDelegates]) {
        [UADSProperties removeDelegate:delegate];
    }
}

- (void)tearDown {
    [super tearDown];
    // reset UADSProperties object
    for (id<UnityAdsDelegate> delegate in [UADSProperties getDelegates]) {
        [UADSProperties removeDelegate:delegate];
    }
}


-(void)testInitializeMultipleTimes {
    UnityAdsDelegateMock *firstDelegate = [[UnityAdsDelegateMock alloc] init];
    [UnityAds initialize:@"mediator1" delegate:firstDelegate];
    XCTAssertEqual([UnityAds getDelegate], firstDelegate);
    UnityAdsDelegateMock *secondDelegate = [[UnityAdsDelegateMock alloc] init];
    [UnityAds initialize:@"mediator2" delegate:secondDelegate];
    XCTAssertEqual([UnityAds getDelegate], firstDelegate);
    XCTAssertEqual([[UADSProperties getDelegates] count], 2);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:firstDelegate]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:secondDelegate]);
}

-(void)testInitializeThenRemove {
    UnityAdsDelegateMock *firstDelegate = [[UnityAdsDelegateMock alloc] init];
    [UnityAds initialize:@"mediator1" delegate:firstDelegate];
    XCTAssertEqual([UnityAds getDelegate], firstDelegate);
    [UnityAds removeDelegate:firstDelegate];
    XCTAssertNil([UnityAds getDelegate]);
}

@end
