#import "NSData+JSONSerialization.h"

@implementation NSData (JSONSerialization)

- (nonnull NSDictionary *)uads_jsonRepresentation {
    NSError *error;
    NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData: self
                                                                     options: kNilOptions
                                                                       error: &error];

    return error == nil ? configDictionary : @{};
}

@end
