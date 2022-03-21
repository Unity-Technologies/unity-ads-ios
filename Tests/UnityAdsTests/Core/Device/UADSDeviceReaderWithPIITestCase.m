#import "UADSDeviceReaderWithPII.h"
#import "UADSJsonStorageReaderMock.h"
#import "UADSDeviceReaderMock.h"
#import "UADSPIIDataSelectorMock.h"
#import "UADSPIIDataProviderMock.h"
#import "UADSJsonStorageKeyNames.h"
#import "NSDictionary+Filter.h"
#import "UADSDeviceReaderWithPIITestCase.h"

@interface UADSDeviceReaderWithPIITestCase ()
@property (nonatomic, strong) UADSJsonStorageReaderMock *jsonStorageMock;
@property (nonatomic, strong) UADSDeviceReaderMock *deviceInfoReaderMock;
@property (nonatomic, strong) UADSPIIDataSelectorMock *selectorMock;
@property (nonatomic, strong) UADSPIIDataProviderMock *dataProviderMock;
@property (nonatomic, strong) id<UADSDeviceInfoReader> sut;
@end

@implementation UADSDeviceReaderWithPIITestCase

- (void)setUp {
    self.jsonStorageMock = [UADSJsonStorageReaderMock new];
    self.deviceInfoReaderMock = [UADSDeviceReaderMock new];
    self.selectorMock = [UADSPIIDataSelectorMock new];
    self.dataProviderMock = [UADSPIIDataProviderMock new];
    self.dataProviderMock.vendorID = [kVendorIDKey stringByAppendingString: @"_device"];
    self.dataProviderMock.advertisingTrackingID = [kAdvertisingTrackingIdKey stringByAppendingString: @"_device"];
    self.sut = [UADSDeviceReaderWithPII newWithOriginal: self.deviceInfoReaderMock
                                        andDataProvider: self.dataProviderMock
                                     andPIIDataSelector: self.selectorMock
                                         andJsonStorage: [self getStorage]];
}

- (id<UADSJsonStorageReader>)getStorage {
    return _jsonStorageMock;
}

- (void)test_includes_keys_passed_from_the_storage_empty_device_info {
    [self saveExpectedContentToJSONStorage: self.fullStorageMockData];
    _selectorMock.expectedData = [UADSPIIDecisionData newIncludeWithAttributes: self.piiExpectedData];
    _deviceInfoReaderMock.expectedInfo = @{};
    XCTAssertEqualObjects([self getDataFromSut], self.piiExpectedData);
}

- (void)test_includes_and_filters_keys_passed_from_the_storage_empty_device_info {
    [self saveExpectedContentToJSONStorage: self.fullStorageMockData];
    NSDictionary *piiFiltered = [self.piiExpectedData uads_filter:^BOOL (id _Nonnull key, id _Nonnull obj) {
        return [key isEqual: [self finalKey: kVendorIDKey]];
    }];

    _selectorMock.expectedData = [UADSPIIDecisionData newIncludeWithAttributes: piiFiltered];
    _deviceInfoReaderMock.expectedInfo = @{};


    XCTAssertEqualObjects([self getDataFromSut], piiFiltered);
}

- (void)test_doesnt_include_pii_info_empty_device_info {
    [self saveExpectedContentToJSONStorage: self.fullStorageMockData];
    _selectorMock.expectedData = [UADSPIIDecisionData newExclude];
    _deviceInfoReaderMock.expectedInfo = @{};
    XCTAssertEqualObjects([self getDataFromSut], @{});
}

- (void)test_updates_values_using_device_empty_device_info {
    [self saveExpectedContentToJSONStorage: self.fullStorageMockData];
    _selectorMock.expectedData = [UADSPIIDecisionData newUpdateWithAttributes: self.piiExpectedData];
    _deviceInfoReaderMock.expectedInfo = @{};
    XCTAssertEqualObjects([self getDataFromSut], self.fullPIIInfoFromDevice);
}

- (void)test_updates_only_required_values_using_device_empty_device_info {
    [self saveExpectedContentToJSONStorage: self.fullStorageMockData];
    NSDictionary *piiFiltered = [self.piiExpectedData uads_filter:^BOOL (id _Nonnull key, id _Nonnull obj) {
        return [key isEqual: [self finalKey: kVendorIDKey]];
    }];

    _selectorMock.expectedData = [UADSPIIDecisionData newUpdateWithAttributes: piiFiltered];
    _deviceInfoReaderMock.expectedInfo = @{};
    NSDictionary *piiFilteredDevice = [self.fullPIIInfoFromDevice uads_filter:^BOOL (id _Nonnull key, id _Nonnull obj) {
        return [key isEqual: [self finalKey: kVendorIDKey]];
    }];

    XCTAssertEqualObjects([self getDataFromSut], piiFilteredDevice);
}

- (void)saveExpectedContentToJSONStorage: (NSDictionary *)content {
    _jsonStorageMock.expectedContent = content;
}

- (NSDictionary *)getDataFromSut {
    return [_sut getDeviceInfoForGameMode: UADSGameModeMix];
}

- (NSDictionary *)piiDecisionContentData {
    return @{
        kVendorIDKey: kVendorIDKey,
        kAdvertisingTrackingIdKey: kAdvertisingTrackingIdKey
    };
}

- (NSDictionary *)piiExpectedData {
    return [self.piiDecisionContentData uads_mapKeys:^id _Nonnull (id _Nonnull key) {
        return [self finalKey: key];
    }];
}

- (NSDictionary *)fullPIIInfoFromDevice {
    return @{
        [self finalKey: kVendorIDKey]: _dataProviderMock.vendorID,
        [self finalKey: kAdvertisingTrackingIdKey]: _dataProviderMock.advertisingTrackingID
    };
}

- (NSDictionary *)fullStorageMockData {
    return @{
        self.piiKey: @{
            kVendorIDKey: kVendorIDKey,
            kAdvertisingTrackingIdKey: kAdvertisingTrackingIdKey
        }
    };
}

- (NSString *)finalKey: (NSString *)original {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: original];
}

- (NSString *)piiKey {
    return [UADSJsonStorageKeyNames piiContainerKey];
}

@end
