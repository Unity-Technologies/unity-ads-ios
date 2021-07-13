NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (SafeOperations)
- (void)uads_setValueIfNotNil: (nullable id)object forKey: (nonnull NSString *)key;
@end

NS_ASSUME_NONNULL_END
