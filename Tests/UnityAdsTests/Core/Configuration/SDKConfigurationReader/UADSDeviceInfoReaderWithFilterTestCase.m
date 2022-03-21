#import <XCTest/XCTest.h>
#import "UADSDictionaryKeysBlockListMock.h"
#import "UADSDeviceReaderMock.h"
#import "UADSDeviceInfoReaderWithFilter.h"
@interface UADSDeviceInfoReaderWithFilterTestCase : XCTestCase
@property (nonatomic, strong)  id<UADSDeviceInfoReader> sut;
@property (nonatomic, strong) UADSDeviceReaderMock *infoReaderMock;
@property (nonatomic, strong) UADSDictionaryKeysBlockListMock *blockListMock;
@end

@implementation UADSDeviceInfoReaderWithFilterTestCase

- (void)setUp {
    self.infoReaderMock = [UADSDeviceReaderMock new];
    self.blockListMock = [UADSDictionaryKeysBlockListMock new];
    self.sut = [UADSDeviceInfoReaderWithFilter newWithOriginal: _infoReaderMock
                                                  andBlockList: _blockListMock];
}

- (void)test_doesnt_filter_if_block_list_is_nil {
    self.infoReaderMock.expectedInfo = self.deviceInfoMockData;
    XCTAssertEqualObjects(self.readDataFromSut, self.deviceInfoMockData);
}

- (void)test_doesnt_filter_if_block_list_is_empty {
    self.infoReaderMock.expectedInfo = self.deviceInfoMockData;
    self.blockListMock.keysToSkip = @[];
    XCTAssertEqualObjects(self.readDataFromSut, self.deviceInfoMockData);
}

- (void)test_filters_values_using_block_list {
    self.infoReaderMock.expectedInfo = self.deviceInfoMockData;
    self.blockListMock.keysToSkip = self.blockListMockData;
    XCTAssertEqualObjects(self.readDataFromSut, self.expectedFilteredData);
}

- (NSDictionary *)readDataFromSut {
    return [self.sut getDeviceInfoForGameMode: UADSGameModeMix];
}

- (NSDictionary *)deviceInfoMockData {
    return @{
        @"key1": @"value1",
        @"key2": @"value2",
        @"key3": @"value3"
    };
}

- (NSArray *)blockListMockData {
    return @[@"key1", @"key3"];
}

- (NSDictionary *)expectedFilteredData {
    return @{
        @"key2": @"value2",
    };
}

@end
