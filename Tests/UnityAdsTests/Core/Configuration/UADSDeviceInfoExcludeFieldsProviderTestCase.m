#import <XCTest/XCTest.h>
#import "UADSDeviceInfoExcludeFieldsProvider.h"
#import "UADSJsonStorageReaderMock.h"
#import "UADSJsonStorageKeyNames.h"

static NSString *const kDefaultMockKeys = @"key1,key2";

@interface UADSDeviceInfoExcludeFieldsProviderTestCase : XCTestCase
@property (nonatomic, strong) UADSDeviceInfoExcludeFieldsProvider *sut;
@property (nonatomic, strong) UADSJsonStorageReaderMock *jsonStorageMock;
@end

@implementation UADSDeviceInfoExcludeFieldsProviderTestCase

- (void)setUp {
    self.jsonStorageMock = [UADSJsonStorageReaderMock new];
    self.sut = [UADSDeviceInfoExcludeFieldsProvider newWithJSONStorage: self.jsonStorageMock];
}

- (void)test_returns_default_keys_if_storage_is_empty {
    XCTAssertEqualObjects(self.sut.keysToSkip, self.expectedDefaultKeys);
}

- (void)test_adds_keys_from_the_storage {
    self.jsonStorageMock.expectedContent = self.defaultMockWebData;
    NSArray *expectedKeys = [self.expectedDefaultKeys arrayByAddingObjectsFromArray: @[@"key1", @"key2"]];

    XCTAssertEqualObjects(self.sut.keysToSkip, expectedKeys);
}

- (void)test_adds_keys_from_an_array_in_the_storage {
    self.jsonStorageMock.expectedContent = @{
        self.excludeValuesKey: @[@"key1", @"key2"]
    };

    NSArray *expectedKeys = [self.expectedDefaultKeys arrayByAddingObjectsFromArray: @[@"key1", @"key2"]];

    XCTAssertEqualObjects(self.sut.keysToSkip, expectedKeys);
}

- (void)test_if_key_doesnt_contain_proper_value_should_return_only_default_keys {
    self.jsonStorageMock.expectedContent = @{
        self.excludeValuesKey: @[@(1), @(2)]
    };
    XCTAssertEqualObjects(self.sut.keysToSkip, self.expectedDefaultKeys);
}

- (NSDictionary *)defaultMockWebData {
    return @{
        self.excludeValuesKey: kDefaultMockKeys
    };
}

- (NSArray *)expectedDefaultKeys {
    return @[];
}

- (NSString *)excludeValuesKey {
    return [UADSJsonStorageKeyNames excludeDeviceInfoKey];
}

@end
