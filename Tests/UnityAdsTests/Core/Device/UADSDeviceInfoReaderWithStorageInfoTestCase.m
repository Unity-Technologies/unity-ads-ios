#import <XCTest/XCTest.h>
#import "UADSJsonStorageReaderMock.h"
#import "UADSDeviceReaderMock.h"
#import "UADSDeviceInfoReaderWithStorageInfo.h"
#import "UADSMetaData.h"
#import "USRVStorageManager.h"
#import "UADSMediationMetaData.h"
#import "UADSDeviceTestsHelper.h"
#import "NSDictionary+Merge.h"

@interface UADSDeviceInfoReaderWithStorageInfoTestCase : XCTestCase
@property (nonatomic, strong) UADSJsonStorageReaderMock *jsonStorageMock;
@property (nonatomic, strong) UADSDeviceReaderMock *originalMock;
@property (nonatomic, strong) UADSDeviceTestsHelper *tester;
@end

@implementation UADSDeviceInfoReaderWithStorageInfoTestCase

- (void)setUp {
    self.tester = [UADSDeviceTestsHelper new];
    [self.tester clearAllStorages];
}

- (void)test_appends_values_from_json_storage_to_output {
    UADSJsonStorageReaderMock *jsonStorageMock = [UADSJsonStorageReaderMock new];
    UADSDeviceReaderMock *originalMock = [UADSDeviceReaderMock new];
    UADSDeviceInfoReaderWithStorageInfo *sut = [UADSDeviceInfoReaderWithStorageInfo decorateOriginal: originalMock
                                                                                andJSONStorageReader: jsonStorageMock
                                                                                   includeContainers: @[]];

    jsonStorageMock.expectedContent = self.mockDataFromJsonStorage;
    originalMock.expectedInfo = self.mockDataFromDeviceReader;
    XCTAssertEqualObjects([sut getDeviceInfoForGameMode: UADSGameModeMix],
                          self.expectedMergedMockDataNonFiltered);
}

- (void)test_filters_and_append_required_payload_to_output {
    UADSDeviceReaderMock *originalMock = [UADSDeviceReaderMock new];
    UADSDeviceInfoReaderWithStorageInfo *sut = [UADSDeviceInfoReaderWithStorageInfo defaultDecorationOfOriginal: originalMock];

    originalMock.expectedInfo = self.mockDataFromDeviceReader;
    [_tester commitAllTestData];

    XCTAssertEqualObjects([sut getDeviceInfoForGameMode: UADSGameModeMix],
                          self.expectedData);
}

- (NSDictionary *)expectedData {
    return [_tester.expectedMergedDataRealStorage uads_newdictionaryByMergingWith: @{
                @"id": @"id",
                @"mode": @"mix",
    }];
}

- (NSDictionary *)expectedMergedMockDataNonFiltered {
    return @{
        @"id": @"id",
        @"mode": @"mix",
        @"framework.name": @"frameworkName",
        @"adapter.version": @"adapterVersion"
    };
}

- (NSDictionary *)mockDataFromDeviceReader {
    return @{
        @"id": @"id",
        @"mode": @"mix"
    };
}

- (NSDictionary *)mockDataFromJsonStorage {
    return @{
        @"framework.name": @"frameworkName",
        @"adapter.version": @"adapterVersion"
    };
}

@end
