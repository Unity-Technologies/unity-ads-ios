#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "UADSWebViewInvoker.h"
#import "UADSInternalError.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSWebViewInvokerMock : NSObject<UADSWebViewInvoker>
@property (nonatomic, strong) XCTestExpectation *expectation;
- (void)emulateCallSuccess;
- (void)emulateCallFailWithError: (UADSInternalError *)error;
- (NSInteger)                                   invokerCalledNumberOfTimes;
- (NSArray<UADSWebViewInvokerCompletion> *)     completions;
- (NSArray<UADSWebViewInvokerErrorCompletion> *)errorCompletions;
- (NSArray<id<UADSWebViewInvokerOperation> > *) operations;
@end

NS_ASSUME_NONNULL_END
