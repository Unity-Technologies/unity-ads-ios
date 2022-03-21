#import <XCTest/XCTest.h>
#import "UADSDeviceIDFIReader.h"
#import "UADSDeviceTestsHelper.h"

@interface UADSDeviceIDFIReaderBaseTestCase : XCTestCase
@property (nonatomic, strong) UADSDeviceTestsHelper *testsHelper;
@end

@implementation UADSDeviceIDFIReaderBaseTestCase

- (void)setUp {
    _testsHelper = [UADSDeviceTestsHelper new];
    [_testsHelper clearAllStorages];
}

- (void)test_reader_returns_current_value {
    [_testsHelper setIDFI];
    XCTAssertEqualObjects(self.sut.idfi, _testsHelper.idfiMockValue);
}

- (void)test_reader_returns_current_session_id_value {
    [_testsHelper setAnalyticSessionID];
    XCTAssertEqualObjects(self.sut.sessionID, _testsHelper.analyticSessionMockValue);
}

- (void)test_reader_returns_current_user_id_value {
    [_testsHelper setAnalyticUserID];
    XCTAssertEqualObjects(self.sut.userID, _testsHelper.analyticUserMockValue);
}

- (void)test_reader_regenerates_new_idfi_if_no_value_found {
    XCTAssertNotEqualObjects(self.sut.idfi, @"");
    XCTAssertNotEqualObjects(self.sut.idfi, _testsHelper.idfiMockValue);
}

- (id<UADSDeviceIDFIReader, UADSAnalyticValuesReader>)sut {
    return [UADSDeviceIDFIReaderBase new];
}

@end
