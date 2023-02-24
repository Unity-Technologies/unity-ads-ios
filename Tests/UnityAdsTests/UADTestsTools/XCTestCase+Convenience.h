#import <XCTest/XCTest.h>
#import "UADSGenericError.h"
#import "UADSTools.h"
NS_ASSUME_NONNULL_BEGIN


typedef void (^ErrorCompletion)(id<UADSError>);
@interface XCTestCase (Category)
- (void)waitForTimeInterval: (NSTimeInterval)waitTime;
- (XCTestExpectation *)defaultExpectation;
- (ErrorCompletion)    failIfError;
- (void)asyncExecuteTimes: (int)count block: (void (^)(XCTestExpectation *expectation, int index))block;
- (void)runBlockAsync: (int)count block: (UADSVoidClosure)closureToPerform;
- (void)               postDidBecomeActive;
- (void)               postDidEnterBackground;

- (void)resetUnityAds;
@end

NS_ASSUME_NONNULL_END
