NS_ASSUME_NONNULL_BEGIN
static NSString *const kNSLocaleCurrencySymbolKey = @"currencySymbol";
static NSString *const kNSLocaleCountryCodeKey = @"countryCode";
static NSString *const kNSLocaleCurrencyCodeKey = @"currencyCode";

@interface NSLocale(PriceDictionary)
-(NSDictionary* _Nonnull )uads_Dictionary;
@end

NS_ASSUME_NONNULL_END
