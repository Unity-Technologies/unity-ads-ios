#import <XCTest/XCTest.h>
#import "UADSWebPlayerSettingsManager.h"

@interface UADSWebPlayerSettingsManagerTests : XCTestCase
@end

@implementation UADSWebPlayerSettingsManagerTests

- (void)testAddWebPlayerSettings {
    UADSWebPlayerSettingsManager *manager = [[UADSWebPlayerSettingsManager alloc] init];
    NSString *testId = @"myCoolView";
    NSDictionary *testDict = @{
            @"testKey": @"testValue"
    };
    [manager addWebPlayerSettings:testId settings:testDict];
    NSDictionary *settings = [manager getWebPlayerSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertEqual(testDict, settings);
}

- (void)testMultipleAddWebPlayerSettings {
    UADSWebPlayerSettingsManager *manager = [[UADSWebPlayerSettingsManager alloc] init];
    NSString *testId = @"myCoolView";
    NSDictionary *testDict = @{
            @"testKey": @"testValue"
    };
    [manager addWebPlayerSettings:testId settings:testDict];
    [manager addWebPlayerSettings:@"2" settings:@{@"hello": @"world"}];
    NSDictionary *settings = [manager getWebPlayerSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertEqual(testDict, settings);

}

- (void)testRemoveWebPlayerSettings {
    UADSWebPlayerSettingsManager *manager = [[UADSWebPlayerSettingsManager alloc] init];
    NSString *testId = @"myCoolView";
    NSDictionary *testDict = @{
            @"testKey": @"testValue"
    };
    [manager addWebPlayerSettings:testId settings:testDict];
    NSDictionary *settings = [manager getWebPlayerSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertEqual(testDict, settings);

    [manager removeWebPlayerSettings:testId];
    settings = [manager getWebPlayerSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertNotEqual(settings, testDict);
    XCTAssertEqual(settings, @{});
}

- (void)testAddWebPlayerEventSettings {
    UADSWebPlayerSettingsManager *manager = [[UADSWebPlayerSettingsManager alloc] init];
    NSString *testId = @"myCoolView";
    NSDictionary *testDict = @{
            @"testKey": @"testValue"
    };
    [manager addWebPlayerEventSettings:testId settings:testDict];
    NSDictionary *settings = [manager getWebPlayerEventSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertEqual(testDict, settings);
}

- (void)testMultipleAddWebPlayerEventSettings {
    UADSWebPlayerSettingsManager *manager = [[UADSWebPlayerSettingsManager alloc] init];
    NSString *testId = @"myCoolView";
    NSDictionary *testDict = @{
            @"testKey": @"testValue"
    };
    [manager addWebPlayerEventSettings:testId settings:testDict];
    [manager addWebPlayerEventSettings:@"2" settings:@{@"foo": @"bar"}];
    NSDictionary *settings = [manager getWebPlayerEventSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertEqual(testDict, settings);
}

- (void)testRemoveWebPlayerEventSettings {
    UADSWebPlayerSettingsManager *manager = [[UADSWebPlayerSettingsManager alloc] init];
    NSString *testId = @"myCoolView";
    NSDictionary *testDict = @{
            @"testKey": @"testValue"
    };
    [manager addWebPlayerEventSettings:testId settings:testDict];
    NSDictionary *settings = [manager getWebPlayerEventSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertEqual(testDict, settings);

    [manager removeWebPlayerEventSettings:testId];
    settings = [manager getWebPlayerEventSettings:testId];

    XCTAssertNotNil(settings);
    XCTAssertNotEqual(settings, testDict);
    XCTAssertEqual(settings, @{});
}

@end
