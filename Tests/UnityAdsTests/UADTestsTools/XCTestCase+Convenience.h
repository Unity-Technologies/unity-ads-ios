#import <XCTest/XCTest.h>
#import "UADSGenericError.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^ErrorCompletion)(id<UADSError>);
@interface XCTestCase (Category)
- (void)waitForTimeInterval: (NSTimeInterval)waitTime;
- (XCTestExpectation *)defaultExpectation;
- (ErrorCompletion)    failIfError;

@end

NS_ASSUME_NONNULL_END
