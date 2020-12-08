#import <XCTest/XCTest.h>
#import "UADSLoadOptions.h"

@interface LoadOptionsTest : XCTestCase

@property UADSLoadOptions* loadOptions;

@end

@implementation LoadOptionsTest

- (void)setUp {
    self.loadOptions = [UADSLoadOptions new];
}

- (void)tearDown {
    self.loadOptions = nil;
}

- (void)testAdMarkup {
    [self.loadOptions setAdMarkup:@"MyAdMarkup"];
    
    XCTAssertEqual(@"MyAdMarkup", [self.loadOptions adMarkup]);
    XCTAssertEqual(@"MyAdMarkup", [self.loadOptions.dictionary objectForKey:@"adMarkup"]);
    
    XCTAssertEqual(1, [self.loadOptions.dictionary count]);
}

- (void)testObjectId {
    [self.loadOptions setObjectId:@"MyObjectId"];
    
    XCTAssertEqual(@"MyObjectId", [self.loadOptions objectId]);
    XCTAssertEqual(@"MyObjectId", [self.loadOptions.dictionary objectForKey:@"objectId"]);
    
    XCTAssertEqual(1, [self.loadOptions.dictionary count]);
}

- (void)testObjectIdAndAdMarkup {
    [self.loadOptions setObjectId:@"MyObjectId"];
    [self.loadOptions setAdMarkup:@"MyAdMarkup"];
    
    XCTAssertEqual(@"MyObjectId", [self.loadOptions objectId]);
    XCTAssertEqual(@"MyObjectId", [self.loadOptions.dictionary objectForKey:@"objectId"]);
    
    XCTAssertEqual(@"MyAdMarkup", [self.loadOptions adMarkup]);
    XCTAssertEqual(@"MyAdMarkup", [self.loadOptions.dictionary objectForKey:@"adMarkup"]);
    
    XCTAssertEqual(2, [self.loadOptions.dictionary count]);
}

@end
