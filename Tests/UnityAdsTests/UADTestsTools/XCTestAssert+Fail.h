
#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
NS_ASSUME_NONNULL_BEGIN
/*!
 * @define XCTAssertFail(...)
 * Generates a failure
 * @param ... An optional supplementary description of the failure. A literal NSString, optionally with string format specifiers. This parameter can be completely omitted.
 */
#define XCTAssertFail(message) XCTAssertFalse(true, message);


NS_ASSUME_NONNULL_END
