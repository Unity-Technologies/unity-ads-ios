#import "UADSConfigurationLoaderWithPersistence.h"

@interface UADSConfigurationLoaderWithPersistence ()
@property (nonatomic, strong) id<UADSConfigurationLoader>original;
@property (nonatomic, strong) id<UADSConfigurationSaver>saver;
@end

@implementation UADSConfigurationLoaderWithPersistence


+ (instancetype)newWithOriginal: (id<UADSConfigurationLoader>)loader andSaver: (id<UADSConfigurationSaver>)saver {
    UADSConfigurationLoaderWithPersistence *decorator = [UADSConfigurationLoaderWithPersistence new];

    decorator.saver = saver;
    decorator.original = loader;
    return decorator;
}

- (void)loadConfigurationWithSuccess: (nonnull UADSConfigurationCompletion NS_NOESCAPE)success
                  andErrorCompletion: (nonnull UADSErrorCompletion NS_NOESCAPE)error {
    id successDecorated = ^(USRVConfiguration *config) {
        [self.saver saveConfiguration: config];
        success(config);
    };

    [self.original loadConfigurationWithSuccess: successDecorated
                             andErrorCompletion: error];
}

@end
