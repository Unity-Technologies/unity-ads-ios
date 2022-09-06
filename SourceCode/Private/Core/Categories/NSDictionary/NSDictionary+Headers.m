#import "NSDictionary+Headers.h"

@implementation NSDictionary (Headers)

+ (NSDictionary<NSString *, NSArray *> *)uads_getHeadersMap: (NSArray *)headers {
    NSMutableDictionary *mappedHeaders = [[NSMutableDictionary alloc] init];

    if (headers && headers.count > 0) {
        for (int idx = 0; idx < headers.count; idx++) {
            if (![[headers objectAtIndex: idx] isKindOfClass: [NSArray class]]) return NULL;

            NSArray *header = [headers objectAtIndex: idx];

            if ([header count] != 2) return NULL;

            if (![[header objectAtIndex: 0] isKindOfClass: [NSString class]] || ![[header objectAtIndex: 1] isKindOfClass: [NSString class]]) {
                return NULL;
            }

            NSString *headerKey = [header objectAtIndex: 0];
            NSString *headerValue = [header objectAtIndex: 1];

            if (headerKey.length < 1) return NULL;

            NSMutableArray *valueList = [[NSMutableArray alloc] initWithArray: [mappedHeaders objectForKey: headerKey]];
            [valueList addObject: headerValue];
            [mappedHeaders setObject: valueList
                              forKey: headerKey];
        }
    }

    return mappedHeaders;
}

+ (NSArray<NSArray<NSString *> *> *)uads_getHeadersArray: (NSDictionary<NSString *, NSString *> *)headersMap {
    __block NSArray *headersArray = [NSArray array];

    if (headersMap && headersMap.count > 0) {
        @try {
            [headersMap enumerateKeysAndObjectsUsingBlock: ^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
                headersArray = [headersArray arrayByAddingObject: @[key, obj]];
            }];
        } @catch (id exception) {
            return NULL;
        }
    }

    return headersArray;
}

+ (NSDictionary<NSString *, NSString *> *)uads_getRequestHeaders: (NSDictionary<NSString *, NSArray *> *)headers {
    if (headers.count == 0) {
        return [NSDictionary dictionary];
    }

    NSMutableDictionary *normalizedHeaders = [NSMutableDictionary dictionaryWithCapacity: headers.count];

    for (NSString *key in [headers allKeys]) {
        NSArray *contents = [headers objectForKey: key];

        if (contents.count > 0) {
            [normalizedHeaders setObject: contents.firstObject
                                  forKey: key];
        }
    }

    return normalizedHeaders;
}

@end
