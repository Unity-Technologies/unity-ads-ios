#import "GMALoaderBase.h"
#import "GADAdInfoBridge.h"
#import "GADRequestBridge.h"
#import "GADRequestBridgeV85.h"
#import "GADResponseInfoBridge.h"

@interface GMALoaderBase ()
@property (nonatomic, strong) GMALoaderBaseStoredObject *currentUsedObj;

@end

@implementation GMALoaderBase

+ (instancetype)newWithRequestFactory: (id<GADRequestFactory>)requestFactory
                   andDelegateFactory: (nonnull id<GMADelegatesFactory>)delegatesFactory {
    return [[self alloc] initWithRequestFactory: requestFactory
                             andDelegateFactory: delegatesFactory];
}

+ (BOOL)isSupported {
    return [GADQueryInfoBridge exists] &&
           ([self isGADRequestSupported] || [self isGADRequestV85Supported]) &&
           [GADResponseInfoBridge exists];
}

+ (BOOL)isGADRequestV85Supported {
    return [GADRequestBridgeV85 exists];
}

+ (BOOL)isGADRequestSupported {
    return [GADRequestBridge exists] && [GADAdInfoBridge exists];
}

- (instancetype)initWithRequestFactory: (id<GADRequestFactory>)requestFactory
                    andDelegateFactory: (nonnull id<GMADelegatesFactory>)delegatesFactory {
    SUPER_INIT;
    self.requestFactory = requestFactory;
    self.delegatesFactory = delegatesFactory;
    self.storage = [[GMALoaderBaseItemStorage alloc] init];
    return self;
}

- (void)showAdUsingMetaData: (GMAAdMetaData *)meta
           inViewController: (UIViewController *)viewController
                      error: (id<UADSError>  _Nullable __autoreleasing *_Nullable)error {
    _currentUsedObj = [_storage objectForKey: meta.placementID];
}

- (void)loadAdUsingMetaData: (nonnull GMAAdMetaData *)meta
              andCompletion: (nonnull UADSLoadAdCompletion *)completion {
    UADS_ABSTRACT_CLASS_EXCEPTION
}

@end
