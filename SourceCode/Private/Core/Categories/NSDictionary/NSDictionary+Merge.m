#import "NSDictionary+Merge.h"
#import "NSMutableDictionary + SafeOperations.h"

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
        id newValue = [newDictionary valueForKey: key];

        if (newValue && [newValue isKindOfClass: [NSDictionary class]] && [obj isKindOfClass: [NSDictionary class]]) {
            [newDictionary setValue: [NSDictionary unityads_dictionaryByMerging: obj
                                                                      secondary: newValue]
                             forKey: key];
        } else {
            [newDictionary setValue: obj
                             forKey: key];
        }
    }];

    return newDictionary;
} /* unityads_dictionaryByMerging */

- (NSDictionary *)uads_newdictionaryByMergingWith: (NSDictionary *)dictionary {
    return [NSDictionary unityads_dictionaryByMerging: self
                                            secondary: dictionary];
}

- (NSDictionary *)uads_flatUsingSeparator: (NSString *)separator
                      includeTopLevelKeys: (NSArray<NSString *> *)topLevelToInclude
                            andReduceKeys: (NSArray<NSString *> *)reduceKeys
                              andSkipKeys: (NSArray<NSString *> *)keysToSkip; {
    NSMutableDictionary *newDictionary = [NSMutableDictionary new];

    for (NSString *key in self.allKeys) {
        if (![self shouldIncludeKey: key
                      keysToInclude: topLevelToInclude
                      andKeysToSkip: keysToSkip]) {
            continue;
        }

        id value = self[key];

        if ([value isKindOfClass: [NSDictionary class]]) {
            [(NSDictionary *)value
             flatUsingSeparator: separator
                  andParentName: key
               outPutDictionary: newDictionary
                  andReduceKeys: reduceKeys
                    andSkipKeys: keysToSkip];
        } else {
            newDictionary[key] = value;
        }
    }

    return newDictionary;
}

- (BOOL)shouldIncludeKey: (NSString *)key
           keysToInclude: (NSArray<NSString *> *)includeList
           andKeysToSkip: (NSArray<NSString *> *)skipList {
    if ([skipList containsObject: key]) {
        return false;
    }

    if (includeList.count <= 0) {
        return true;
    }

    return [includeList containsObject: key];
}

- (void)flatUsingSeparator: (NSString *)separator
             andParentName: (NSString *)name
          outPutDictionary: (NSMutableDictionary *)outputDictionary
             andReduceKeys: (NSArray<NSString *> *)reduceKeys
               andSkipKeys: (NSArray<NSString *> *)keysToSkip {
    for (NSString *key in self.allKeys) {
        if ([keysToSkip containsObject: key]) {
            continue;
        }

        id value = self[key];
        NSString *newKey;

        if ([reduceKeys containsObject: key]) {
            newKey = name;
        } else {
            newKey = [NSString stringWithFormat: @"%@%@%@", name, separator, key ];
        }

        if ([value isKindOfClass: [NSDictionary class]]) {
            [(NSDictionary *)value
             flatUsingSeparator: separator
                  andParentName: newKey
               outPutDictionary: outputDictionary
                  andReduceKeys: reduceKeys
                    andSkipKeys: keysToSkip];
        } else {
            outputDictionary[newKey] = value;
        }
    }
}

@end
