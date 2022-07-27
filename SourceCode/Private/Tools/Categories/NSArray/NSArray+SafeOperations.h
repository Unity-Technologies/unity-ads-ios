NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType>(Category)
- (_Nullable ObjectType)uads_getItemSafelyAtIndex: (NSInteger)index;

- (instancetype)uads_removingFirstElements: (unsigned long)count;
@end

NS_ASSUME_NONNULL_END
