#import "GMAQueryInfoReader.h"
#import <XCTest/XCTest.h>
NS_ASSUME_NONNULL_BEGIN

@interface GMABaseQueryInfoReader (TestCategory)
+ (GADQueryInfoBridge *)getQueryInfoSyncOfType: (GADQueryInfoAdType)type
                                   forTestCase: (XCTestCase *)testCase;
@end

NS_ASSUME_NONNULL_END
