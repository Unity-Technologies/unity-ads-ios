#import <XCTest/XCTest.h>
#import "UADSConfigurationEndpointProvider.h"
#import "UADSPlistReaderMock.h"
#import "USRVStorageManager.h"
@interface UADSConfigurationEndpointProviderTestCase : XCTestCase
@property (nonatomic, strong) id<UADSHostnameProvider> sut;
@property (nonatomic, strong) UADSPlistReaderMock *plistReaderMock;
@end

@implementation UADSConfigurationEndpointProviderTestCase

- (void)setUp {
    self.plistReaderMock = [UADSPlistReaderMock new];
    self.sut = UADSConfigurationEndpointProvider.defaultProvider;
}

- (void)test_if_there_is_no_flag_set_in_the_meta_data_should_return_default_host_name {
    XCTAssertEqualObjects(_sut.hostname, self.expectedDefaultHostName);
}

- (void)test_if_ther_is_a_config_value_in_plist_should_use_it {
    self.sut = [UADSConfigurationEndpointProvider newWithPlistReader: _plistReaderMock ];
    NSString *expectedConfigVersion = @"configVersion";

    _plistReaderMock.expectedValue = expectedConfigVersion;
    XCTAssertEqualObjects(_sut.hostname, [self expectedNameWithConfigName: expectedConfigVersion]);
}

- (NSString *)expectedDefaultHostName {
    return [self expectedNameWithConfigName: kDefaultConfigVersion];
}

- (NSString *)expectedNameWithConfigName: (NSString *)config {
    return [config stringByAppendingFormat: @".%@", kDefaultConfigHostNameBase];
}

@end
