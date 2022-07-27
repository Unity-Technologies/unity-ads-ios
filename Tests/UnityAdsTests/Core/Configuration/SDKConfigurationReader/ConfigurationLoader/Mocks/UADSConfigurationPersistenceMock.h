#import "UADSConfigurationSaverWithTokenStorage.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationPersistenceMock : NSObject<UADSConfigurationSaver>
@property (nonatomic, strong) id<UADSConfigurationSaver> original;
@property (nonatomic, strong) NSArray<USRVConfiguration *> *receivedConfig;
@end

NS_ASSUME_NONNULL_END
