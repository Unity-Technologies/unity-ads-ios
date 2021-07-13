NS_ASSUME_NONNULL_BEGIN

@interface GMAGenericAdsDelegateObject<__covariant AdType, __covariant DelegateType> : NSObject
@property (strong, nonatomic, readonly) AdType storedAd;
@property (strong, nonatomic, readonly) DelegateType storedDelegate;

+ (instancetype)newWithAd: (AdType)ad delegate: (DelegateType)delegate;
@end

NS_ASSUME_NONNULL_END
