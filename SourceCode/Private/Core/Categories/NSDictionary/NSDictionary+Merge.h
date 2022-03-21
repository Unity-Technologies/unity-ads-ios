@interface NSDictionary (Merge)

+ (NSDictionary *)unityads_dictionaryByMerging: (NSDictionary *)primary secondary: (NSDictionary *)secondary;

- (NSDictionary *)uads_newdictionaryByMergingWith: (NSDictionary *)dictionary;

- (NSDictionary *)uads_flatUsingSeparator: (NSString *)separator
                      includeTopLevelKeys: (NSArray<NSString *> *)topLevelToInclude
                            andReduceKeys: (NSArray<NSString *> *)reduceKeys
                              andSkipKeys: (NSArray<NSString *> *)keysToSkip;
@end
