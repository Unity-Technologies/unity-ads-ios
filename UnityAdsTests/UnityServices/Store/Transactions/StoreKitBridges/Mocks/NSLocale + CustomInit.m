#import "NSLocale + CustomInit.h"

@implementation NSLocale(CustomInit)
+ (instancetype)newForUS {
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
    return locale;
}

+ (NSDictionary *)defaultTestData {
    NSMutableDictionary *mDictionary = [NSMutableDictionary new];
    mDictionary[kNSLocaleCountryCodeKey] = @"US";
    mDictionary[kNSLocaleCurrencySymbolKey] = @"$";
    mDictionary[kNSLocaleCurrencyCodeKey] = @"USD";
    return  mDictionary;
}
@end
