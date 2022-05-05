#import <XCTest/XCTest.h>
#import "USRVJsonStorageAggregator.h"
#import "NSArray + Map.h"
#import "UADSJsonStorageReaderMock.h"

@interface USRVJsonStorageAggregatorTestCase : XCTestCase

@end

@implementation USRVJsonStorageAggregatorTestCase


- (void)test_on_single_data_set {
    id<UADSJsonStorageContentsReader> sut = [self sutForDataSets: @[self.dataSet1]];

    XCTAssertEqualObjects([sut getContents], self.dataSet1);
}

- (void)test_on_two_different_data_set {
    id<UADSJsonStorageContentsReader> sut = [self sutForDataSets: @[self.dataSet1, self.dataSet2]];

    XCTAssertEqualObjects([sut getContents], self.expectedMergedResult);
}

- (void)test_on_two_identical_data_set {
    id<UADSJsonStorageContentsReader> sut = [self sutForDataSets: @[self.dataSet2, self.dataSet2]];

    XCTAssertEqualObjects([sut getContents], self.dataSet2);
}

- (void)test_get_value_for_key_doesnt_call_the_next_reader_when_a_value_found {
    UADSJsonStorageReaderMock *firstReader = [UADSJsonStorageReaderMock new];

    firstReader.expectedContent = self.dataSet1;

    UADSJsonStorageReaderMock *secondReader = [UADSJsonStorageReaderMock new];

    secondReader.expectedContent = self.dataSet2;
    USRVJsonStorageAggregator *sut = [USRVJsonStorageAggregator newWithReaders: @[firstReader, secondReader]];

    XCTAssertEqualObjects([sut getValueForKey: @"key1"], @"value1");
    XCTAssertEqual(secondReader.requestedKeys.count, 0);
}

- (void)test_get_value_for_key_returns_nil_if_not_found {
    UADSJsonStorageReaderMock *firstReader = [UADSJsonStorageReaderMock new];

    firstReader.expectedContent = self.dataSet1;

    UADSJsonStorageReaderMock *secondReader = [UADSJsonStorageReaderMock new];

    secondReader.expectedContent = self.dataSet2;
    USRVJsonStorageAggregator *sut = [USRVJsonStorageAggregator newWithReaders: @[firstReader, secondReader]];

    NSString *keyNonExisted = @"key_random";

    XCTAssertEqualObjects([sut getValueForKey: keyNonExisted], nil);
    XCTAssertEqualObjects(firstReader.requestedKeys, @[keyNonExisted]);
    XCTAssertEqualObjects(secondReader.requestedKeys, @[keyNonExisted]);
}

- (id<UADSJsonStorageContentsReader>)sutForDataSets: (NSArray<NSDictionary *> *)dataSets {
    NSArray<id<UADSJsonStorageContentsReader> > *readers = [dataSets uads_mapObjectsUsingBlock:^id _Nonnull (NSDictionary *_Nonnull obj) {
        UADSJsonStorageReaderMock *mock = [UADSJsonStorageReaderMock new];
        mock.expectedContent = obj;
        return mock;
    }];

    return [USRVJsonStorageAggregator newWithReaders: readers];
}

- (NSDictionary *)dataSet1 {
    return @{
        @"key1": @"value1",
    };
}

- (NSDictionary *)dataSet2 {
    return @{
        @"key2": @"value2",
        @"nestedObject": @{
            @"key3": @"value3"
        },
    };
}

- (NSDictionary *)expectedMergedResult {
    return @{
        @"key1": @"value1",
        @"key2": @"value2",
        @"nestedObject": @{
            @"key3": @"value3"
        },
    };
}

@end
