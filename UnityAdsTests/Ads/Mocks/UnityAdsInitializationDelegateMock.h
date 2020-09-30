#import "UnityAdsInitializationDelegate.h"
#import <XCTest/XCTest.h>

@interface UnityAdsInitializationDelegateMock : NSObject <UnityAdsInitializationDelegate>
@property(nonatomic, assign) BOOL didInitializeSuccessfully;
@property(nonatomic, assign) UnityAdsInitializationError didInitializeFailedError;
@property(strong) NSMutableArray* didInitializeFailedErrorMessage;
@property (nonatomic, strong) XCTestExpectation *expectation;

- (void)initializationComplete;
- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(NSString *)message;

@end
