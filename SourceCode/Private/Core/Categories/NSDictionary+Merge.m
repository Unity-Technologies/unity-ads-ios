#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

+ (NSDictionary *)unityads_dictionaryByMerging: (NSDictionary *)primary secondary: (NSDictionary *)secondary {
    if (!primary) {
        return secondary;
    }

    if (!secondary) {
        return primary;
    }

    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary: secondary];

    [primary enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([newDictionary valueForKey: key] && [[newDictionary valueForKey: key] isKindOfClass: [NSDictionary class]] && [obj isKindOfClass: [NSDictionary class]]) {
            [newDictionary setValue: [NSDictionary unityads_dictionaryByMerging: obj
                                                                      secondary: [newDictionary valueForKey: key]]
                             forKey: key];
        } else {
            [newDictionary setValue: obj
                             forKey: key];
        }
    }];

    return newDictionary;
} /* unityads_dictionaryByMerging */

@end
