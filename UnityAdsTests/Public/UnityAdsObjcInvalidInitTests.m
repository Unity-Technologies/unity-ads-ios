#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "UnityAdsTests-Swift.h"

@interface UnityAdsObjcInvalidInitTests : XCTestCase <UnityAdsDelegate> {
    XCTestExpectation *initializedFailureExpectation;
    XCTestExpectation *initFailedWithInitSanityCheckFailure;
    XCTestExpectation *initFailedWithInitializedFailure;
    XCTestExpectation *initFailedWithInvalidArguementFailure;
    XCTestExpectation *initFailedWithNotInitialized;
    UnityAdsError currentError;
}
@end

@implementation UnityAdsObjcInvalidInitTests

- (void)setUp {
    [super setUp];
    currentError = 0;
    [UnityAds resetForTest];
}

- (void)tearDown {
    [UnityAds resetForTest];
    [super tearDown];
}

- (void)testInitializeWithEmptyStringGameIdentifier {
    initFailedWithInvalidArguementFailure = [self expectationWithDescription:@"initialization with empty string game identifier should fail"];
    
    [UnityAds initialize:@"" delegate:self];
    
    [self waitForExpectationsWithTimeout:[UnityAdsTestConstants networkFetchInterval] handler:^(NSError * _Nullable error) {
        if (error != nil && error.code != 0) {
            XCTFail(@"error waiting for unityAdsDidError: withMessage: to be called");
        } else {
            XCTAssert(currentError == kUnityAdsErrorInvalidArgument, @"should have received an invalid arguement error");
        }
    }];
}

- (void)DISABLED_testInitializeWithNonNumericStringGameIdentifier {
    initFailedWithInvalidArguementFailure = [self expectationWithDescription:@"initialization with non-numeric string for game identifier should fail"];
    
    [UnityAds initialize:[UnityAdsTestConstants nonNumericGameIdString] delegate:self];
    
    [self waitForExpectationsWithTimeout:[UnityAdsTestConstants networkFetchInterval] handler:^(NSError * _Nullable error) {
        if (error != nil && error.code != 0) {
            XCTFail(@"error waiting for unityAdsDidError: withMessage: to be called");
        } else {
            XCTAssert(currentError == kUnityAdsErrorInvalidArgument, @"should have received an invalid arguement error");
        }
    }];
}

# pragma mark UnityAdsDelegate Selectors

- (void)unityAdsReady:(NSString *)placementId {
}

- (void)unityAdsDidClick:(NSString *)placementId {
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    // Verify that an error has been emitted and fulfill expectations based on type
    if (error) {
        if (error == kUnityAdsErrorInvalidArgument) {
            currentError = error;
            [initFailedWithInvalidArguementFailure fulfill];
        }
        if (error == kUnityAdsErrorInitializedFailed) {
            [initializedFailureExpectation fulfill];
        }
    }
}

- (void)unityAdsDidStart:(NSString *)placementId {
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
}

@end
