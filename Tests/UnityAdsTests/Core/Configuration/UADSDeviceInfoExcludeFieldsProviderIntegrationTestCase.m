#import <XCTest/XCTest.h>
#import "UADSDeviceInfoExcludeFieldsProvider.h"
#import "USRVStorageManager.h"
#import "UADSMetaData.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSDeviceInfoExcludeFieldsProviderIntegrationTestCase : XCTestCase

@end

@implementation UADSDeviceInfoExcludeFieldsProviderIntegrationTestCase

- (void)setUp {
    USRVStorage *storage = [USRVStorageManager getStorage: self.storageType];

    [storage clearStorage];
    [storage initStorage];
}

- (void)test_returns_empty_keys_from_the_storage {
    XCTAssertEqualObjects(self.sut.keysToSkip, @[]);
}

- (void)test_returns_an_array_when_the_value_is_string {
    [self commitExcludeData: @"key1,key2"];
    XCTAssertEqualObjects(self.sut.keysToSkip, self.expectedData);
}

- (void)test_returns_an_array_when_the_value_is_an_array {
    [self commitExcludeData: self.expectedData];
    XCTAssertEqualObjects(self.sut.keysToSkip, self.expectedData);
}

- (UADSDeviceInfoExcludeFieldsProvider *)sut {
    return [UADSDeviceInfoExcludeFieldsProvider defaultProvider];
}

- (void)commitExcludeData: (id)excludeValue {
    USRVJsonStorage *storage = [USRVStorageManager getStorage: self.storageType];

    [storage set: self.excludeValueKey
           value :  excludeValue];
}

- (UnityServicesStorageType)storageType {
    return kUnityServicesStorageTypePrivate;
}

- (NSArray *)expectedData {
    return @[@"key1", @"key2"];
}

- (NSString *)excludeValueKey {
    return [UADSJsonStorageKeyNames excludeDeviceInfoKey];
}

@end
