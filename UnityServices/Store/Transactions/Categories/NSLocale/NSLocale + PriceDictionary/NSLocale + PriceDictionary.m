#import "NSLocale + PriceDictionary.h"
#import "NSMutableDictionary + SafeOperations.h"

@implementation NSLocale(PriceDictionary)
- (NSDictionary *)uads_Dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary uads_setValueIfNotNil: [self valueForKey: kNSLocaleCurrencySymbolKey]
                               forKey: kNSLocaleCurrencySymbolKey];
    
    [dictionary uads_setValueIfNotNil: [self valueForKey: kNSLocaleCountryCodeKey]
                               forKey: kNSLocaleCountryCodeKey];
    
    [dictionary uads_setValueIfNotNil: [self valueForKey: kNSLocaleCurrencyCodeKey]
                               forKey: kNSLocaleCurrencyCodeKey];
    
    
    return dictionary;
}
@end
