#import "GMAError.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMAError (XCTest)
- (void)testWithEventName: (NSString *)name
                expParams: (NSArray *)params;
@end

NS_ASSUME_NONNULL_END
