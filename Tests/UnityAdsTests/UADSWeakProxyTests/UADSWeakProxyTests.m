//
//  UADSWeakProxyTests.m
//  UnityAdsTests
//
//  Created by Alex Crowe on 2020-10-13.
//

#import <XCTest/XCTest.h>
#import "UADSWeakProxy.h"

typedef bool (^ConditionClosure)(void);
#define DEFAULT_STEP 0.002
@interface UADSWeakProxyTests : XCTestCase
@property (nonatomic) int iterations;
@end

@implementation UADSWeakProxyTests

- (void)setUp {
    self.iterations = 10000;
}

- (void)testProxyReturnsSameResult {
    NSNumber *numberOne = @1;
    id proxy = [UADSWeakProxy newWithObject: numberOne];

    XCTAssertEqualObjects([numberOne stringValue],
                          [proxy stringValue],
                          @"proxy MUST return same result as object");
}

- (void)testProxyWorksWithNilObject {
    id proxy = [UADSWeakProxy newWithObject: [[NSObject alloc] init]];

    XCTAssertNil([proxy copy],
                 @"proxy MUST work with a nil object");
}

// This "test" is simply to give us a reference for the proxy's performance
- (void)testMessagePerformance {
    NSNumber *numberOne = @1;

    [self measureBlock: ^{
        for (int i = 0; i < _iterations; i += 1) {
            [numberOne stringValue];
        }
    }];
}

// If you comment out forwardingTargetForSelector: in TPDWeakProxy.m, you can
// see how much faster the fast path is than the slow path.
// - (void)testMessageProxyPerformance {
//    NSNumber *numberOne = @1;
//    id proxy = [UADSWeakProxy newWithObject: numberOne];
//    [self measureBlock:^{
//        for (int i = 0; i < _iterations; i += 1) {
//            [proxy stringValue];
//        }
//    }];
// }


@end
