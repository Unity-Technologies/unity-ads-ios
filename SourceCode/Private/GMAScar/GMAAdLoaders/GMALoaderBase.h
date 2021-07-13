#import "UADSGenericError.h"
#import "GMAQuerySignalReader.h"
#import "UADSGenericError.h"
#import <UIKit/UIKit.h>
#import "GMAGenericAdsDelegateObject.h"
#import "GADBaseAd.h"
#import "GMAAdMetaData.h"
#import "GMADelegatesFactory.h"
NS_ASSUME_NONNULL_BEGIN

@protocol UADSAdPresenter<NSObject>
- (void)showAdUsingMetaData: (GMAAdMetaData *)meta
           inViewController: (UIViewController *)viewController
                      error: (id<UADSError>  _Nullable __autoreleasing *_Nullable)error;
@end


typedef UADSGenericCompletion<GADBaseAd *> UADSLoadAdCompletion;

@protocol GMAAdLoader<NSObject>
- (void)loadAdUsingMetaData: (GMAAdMetaData *)meta
              andCompletion: (UADSLoadAdCompletion *)completion;

@end


@interface GMALoaderBase<__covariant AdType, __covariant DelegateType>: NSObject<GMAAdLoader, UADSAdPresenter>

typedef GMAGenericAdsDelegateObject<AdType, DelegateType>            GMALoaderBaseStoredObject;
typedef NSMutableDictionary<NSString *, GMALoaderBaseStoredObject *> GMALoaderBaseItemStorage;

@property (strong, nonatomic) GMALoaderBaseItemStorage *storage;
@property (strong, nonatomic) id<GADRequestFactory> requestFactory;
@property (strong, nonatomic) id<GMADelegatesFactory> delegatesFactory;

+ (instancetype)newWithRequestFactory: (id<GADRequestFactory>)requestFactory
                   andDelegateFactory: (id<GMADelegatesFactory>)delegatesFactory;
+ (BOOL)        isSupported;

@end

NS_ASSUME_NONNULL_END
