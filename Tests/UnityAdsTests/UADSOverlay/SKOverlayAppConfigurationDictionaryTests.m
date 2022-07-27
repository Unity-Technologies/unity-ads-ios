#import <XCTest/XCTest.h>
#import "SKOverlayAppConfiguration+Dictionary.h"

@interface SKOverlayAppConfigurationDictionaryTests : XCTestCase

@end

@implementation SKOverlayAppConfigurationDictionaryTests

- (void)test_creates_configuration_with_correct_parameters {
    NSDictionary *parameters = @{
        @"appIdentifier": @"871767552",
        @"position": @"1",
        @"userDismissible": @"1",
        @"campaignToken": @"token1",
        @"providerToken": @"token2",
        @"latestReleaseID": @"releaseID",
        @"customProductPageIdentifier": @"customID",
        @"additional": @{
            @"additionalKey1": @"additionalValue1",
            @"additionalKey2": @"additionalValue2"
        }
    };

    if (@available(iOS 14.0, *)) {
        SKOverlayAppConfiguration *config = [SKOverlayAppConfiguration uads_overlayAppConfigurationFrom: parameters];

        XCTAssertEqual(config.appIdentifier,  [parameters valueForKey: @"appIdentifier"]);
        XCTAssertEqual(config.position, [[parameters valueForKey: @"position"] intValue]);
        XCTAssertEqual(config.userDismissible, [[parameters valueForKey: @"userDismissible"] boolValue]);
        XCTAssertEqual(config.campaignToken,  [parameters valueForKey: @"campaignToken"]);
        XCTAssertEqual(config.providerToken,  [parameters valueForKey: @"providerToken"]);

        if (@available(iOS 15.0, *)) {
            XCTAssertEqual(config.latestReleaseID,  [parameters valueForKey: @"latestReleaseID"]);
            XCTAssertEqual(config.customProductPageIdentifier,  [parameters valueForKey: @"customProductPageIdentifier"]);
        }

        [[parameters valueForKey: @"additional"] enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            XCTAssertEqual([config additionalValueForKey: key],  obj);
        }];
    }
}

- (void)test_returns_nil_configuration_if_appIdentifier_is_not_set {
    NSDictionary *parameters = @{
        @"position": @"1",
        @"userDismissible": @"1",
    };

    if (@available(iOS 14.0, *)) {
        SKOverlayAppConfiguration *config = [SKOverlayAppConfiguration uads_overlayAppConfigurationFrom: parameters];
        XCTAssertNil(config);
    }
}

@end
