#import "GMALoaderBase.h"
#import "GMAAdMetaData.h"
NS_ASSUME_NONNULL_BEGIN

@protocol GMAVersionChecker <NSObject>
- (NSString *)  currentVersion;
- (BOOL)        isSupported;
@end

@interface GMAAdLoaderStrategy : NSObject<GMAAdLoader, UADSAdPresenter, GMAVersionChecker>

+ (instancetype)newWithRequestFactory: (id<GADRequestFactory>)requestFactory
                   andDelegateFactory: (nonnull id<GMADelegatesFactory>)delegatesFactory;

- (void)showAdUsingMetaData: (GMAAdMetaData *)meta
           inViewController: (UIViewController *)viewController
                      error: (id<UADSError>  _Nullable __autoreleasing *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
