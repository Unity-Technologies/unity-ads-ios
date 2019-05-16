#import <XCTest/XCTest.h>
#import "UADSProperties.h"
#import "UnityAdsDelegateMock.h"

@interface UADSPropertiesTests: XCTestCase
@end

@implementation UADSPropertiesTests

- (void)setUp {
    [super setUp];
    // reset UADSProperties object
    for (id<UnityAdsDelegate> delegate in [UADSProperties getDelegates]) {
        [UADSProperties removeDelegate:delegate];
    }
    [UADSProperties setShowTimeout:UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT];
}

- (void)tearDown {
    [super tearDown];
    // reset UADSProperties object
    for (id<UnityAdsDelegate> delegate in [UADSProperties getDelegates]) {
        [UADSProperties removeDelegate:delegate];
    }
    [UADSProperties setShowTimeout:UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT];
}

- (void)testAddDelegate {
    UnityAdsDelegateMock *delegate = [[UnityAdsDelegateMock alloc] init];
    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);
    [UADSProperties addDelegate:delegate];
    XCTAssertEqual(1, [[UADSProperties getDelegates] count]);
    XCTAssertEqual(delegate, [[UADSProperties getDelegates] firstObject]);
    [UADSProperties removeDelegate:delegate];
    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);
}

- (void)testAddMultipleDelegates {
    UnityAdsDelegateMock *delegate1 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate2 = [[UnityAdsDelegateMock alloc] init];
    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);
    [UADSProperties addDelegate:delegate1];
    [UADSProperties addDelegate:delegate2];
    XCTAssertEqual(2, [[UADSProperties getDelegates] count]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate1]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate2]);
    [UADSProperties removeDelegate:delegate1];
    [UADSProperties removeDelegate:delegate2];
    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);
}

- (void)testSetShowTimeout {
    XCTAssertEqual(UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT, [UADSProperties getShowTimeout]);
    [UADSProperties setShowTimeout:100];
    XCTAssertEqual(100, [UADSProperties getShowTimeout]);
    [UADSProperties setShowTimeout:UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT];
    XCTAssertEqual(UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT, [UADSProperties getShowTimeout]);
}

@end
