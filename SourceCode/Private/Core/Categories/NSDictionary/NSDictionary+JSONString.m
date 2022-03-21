#import "NSDictionary+JSONString.h"

@implementation NSDictionary (JSONString)
- (NSString *)jsonEncodedString {
    NSData *jsonData = [self jsonData];

    if (!jsonData) {
        return @"";
    }

    return [[NSString alloc] initWithData: jsonData
                                 encoding: NSUTF8StringEncoding];
}

- (NSData *)jsonData {
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: self
                                                       options: 0
                                                         error: &err];

    if (err) {
        return nil;
    }

    GUARD_OR_NIL(jsonData)
    return jsonData;
}

- (NSString *)queryString {
    __block NSString *queryString = @"";
    __block BOOL first = true;

    [self enumerateKeysAndObjectsUsingBlock: ^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if (first) {
            queryString = [NSString stringWithFormat: @"?%@%@=%@", queryString, key, obj];
            first = false;
        } else {
            queryString = [NSString stringWithFormat: @"%@&%@=%@", queryString, key, obj];
        }
    }];

    return queryString;
}

- (BOOL)isEmpty {
    return self.count <= 0;
}

@end
