#import <XCTest/XCTest.h>
#import "UADSShowOptions.h"

@interface ShowOptionsTest : XCTestCase

@property UADSShowOptions* showOptions;

@end

@implementation ShowOptionsTest

- (void)setUp {
    self.showOptions = [UADSShowOptions new];
}

- (void)tearDown {
    self.showOptions = nil;
}

- (void)testObjectId {
    [self.showOptions setObjectId:@"MyObjectId"];
    XCTAssertEqual(@"MyObjectId", [self.showOptions objectId]);
    XCTAssertEqual(@"MyObjectId", [self.showOptions.dictionary objectForKey:@"objectId"]);
    XCTAssertEqual(1, [self.showOptions.dictionary count]);
}

@end
