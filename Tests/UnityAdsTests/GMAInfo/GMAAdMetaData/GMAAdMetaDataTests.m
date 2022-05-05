#import <XCTest/XCTest.h>
#import "GMAAdMetaData.h"

@interface GMAAdMetaDataTests : XCTestCase

@end

@implementation GMAAdMetaDataTests

- (void)test_gets_correct_video_length {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.videoLength = @30345;
    XCTAssertEqual([meta videoLengthInSeconds], 30.345);

    meta.videoLength = @56;
    XCTAssertEqual([meta videoLengthInSeconds], 56);

    meta.videoLength = @1000;
    XCTAssertEqual([meta videoLengthInSeconds], 1);

    meta.videoLength = @1001;
    XCTAssertEqual([meta videoLengthInSeconds], 1.001);

    meta.videoLength = @1;
    XCTAssertEqual([meta videoLengthInSeconds], 1);

    meta.videoLength = @4.5;
    XCTAssertEqual([meta videoLengthInSeconds], 4.5);

    meta.videoLength = @10456.4;
    XCTAssertEqual([meta videoLengthInSeconds], 10.4564);

    meta.videoLength = @100.5;
    XCTAssertEqual([meta videoLengthInSeconds], 100.5);

    meta.videoLength = @0;
    XCTAssertEqual([meta videoLengthInSeconds], 0);
}

@end
