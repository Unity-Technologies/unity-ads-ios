#import <XCTest/XCTest.h>
#import "SKProductBridge+Dictionary.h"
#import "SKProduct+CustomInit.h"
#import "NSLocale+CustomInit.h"
#import "SKProductSubscriptionPeriod+CustomInit.h"
#import "SKProductDiscount+CustomInit.h"

#define FALSE_AS_NUMBER [NSNumber numberWithBool: false]

@interface SKProductBridgeTests : XCTestCase

@end

@implementation SKProductBridgeTests


- (void)test_returns_proper_identifier {
    XCTAssertEqualObjects(self.defaultMock.productIdentifier,
                          self.skProductDictionary[kProductIdentifierKey]);
}

- (void)test_returns_proper_localized_title {
    XCTAssertEqualObjects(self.defaultMock.localizedTitle,
                          self.skProductDictionary[kLocalizedTitleKey]);
}

- (void)test_returns_proper_localized_description {
    XCTAssertEqualObjects(self.defaultMock.localizedDescription,
                          self.skProductDictionary[kLocalizedDescriptionKey]);
}

- (void)test_returns_proper_price_locale {
    [self compareNSLocale: self.defaultMock.priceLocale
         withExpectedData: self.nsLocaleDictionary];
}

- (void)test_access_isDownloadable_doesnt_crash {
    XCTAssertEqualObjects(self.defaultMock.isDownloadableNumber,
                          FALSE_AS_NUMBER);
}

- (void)test_access_isFamilySharable_doesnt_crash {
    XCTAssertEqualObjects(self.defaultMock.isDownloadableNumber,
                          FALSE_AS_NUMBER);
}

- (void)test_access_subscription_identifier_doesnt_crash {
    XCTAssertEqualObjects(self.defaultMock.subscriptionGroupIdentifier,
                          nil);
}

- (void)test_returns_proper_number_of_units {
    XCTAssertEqualObjects(self.defaultMock.subscriptionPeriod.numberOfUnitsNumber,
                          self.skPeriodDictionary[kSKProductSubscriptionNumberOfUnitsKey]);
}

- (void)test_returns_proper_units {
    XCTAssertEqualObjects(self.defaultMock.subscriptionPeriod.unitNumber,
                          self.skPeriodDictionary[kSKProductSubscriptionUnitKey]);
}

- (void)test_returns_proper_price {
    XCTAssertEqualObjects(self.defaultMock.price,
                          self.skProductDictionary[kSKProductDiscountPriceKey]);
}

- (void)test_returns_proper_introductory_price_locale {
    if (@available(iOS 11.2, *)) {
        [self compareProductDiscount: self.defaultMock.introductoryPrice
                    withExpectedData: self.skProductDiscountDictionary];
    }
}

- (void)test_return_proper_discounts {
    [self.defaultMock.discounts enumerateObjectsUsingBlock: ^(SKProductDiscountBridge *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self compareProductDiscount: obj
                    withExpectedData: self.skProductDiscountDictionary];
    }];
}

- (void)compareNSLocale: (NSLocale *)locale
       withExpectedData: (NSDictionary *)dictionary {
    if (@available(iOS 12.0, *)) {
        XCTAssertEqualObjects(locale.currencyCode,
                              dictionary[kNSLocaleCurrencyCodeKey]);
        XCTAssertEqualObjects(locale.currencySymbol,
                              dictionary[kNSLocaleCurrencySymbolKey]);
        XCTAssertEqualObjects(locale.countryCode,
                              dictionary[kNSLocaleCountryCodeKey]);
    }
}

- (void)compareProductDiscount: (SKProductDiscountBridge *)discount
              withExpectedData: (NSDictionary *)dictionary  {
    [self compareNSLocale: discount.priceLocale
         withExpectedData: self.nsLocaleDictionary];

    if (@available(iOS 12.0, *)) {
        XCTAssertEqualObjects(discount.identifier, dictionary[kSKProductDiscountIDKey]);
    } else {
        XCTAssertEqualObjects(discount.identifier, nil);
    }

    XCTAssertEqualObjects(discount.price, dictionary[kSKProductDiscountPriceKey]);
    XCTAssertEqualObjects(discount.numberOfPeriodsNumber, dictionary[kSKProductDiscountNumberOfPeriodsKey]);
    XCTAssertEqualObjects(discount.paymentModeNumber, dictionary[kSKProductDiscountPaymentModeKey]);
    XCTAssertEqualObjects(discount.typeNumber, dictionary[kSKProductDiscountTypeKey]);
}

- (SKProductBridge *)defaultMock {
    SKProduct *mock = [SKProduct newFromDictionary: self.skProductDictionary];

    return [SKProductBridge getProxyWithObject: mock];
}

- (NSDictionary *)nsLocaleDictionary {
    return [NSLocale defaultTestData];
}

- (NSDictionary *)skProductDictionary {
    return [SKProduct defaultTestData];
}

- (NSDictionary *)skPeriodDictionary {
    if (@available(iOS 11.2, *)) {
        return [SKProductSubscriptionPeriod defaultTestData];
    } else {
        return nil;
    }
}

- (NSDictionary *)skProductDiscountDictionary {
    if (@available(iOS 11.2, *)) {
        return [SKProductDiscount defaultTestData];
    } else {
        return nil;
    }
}

@end
