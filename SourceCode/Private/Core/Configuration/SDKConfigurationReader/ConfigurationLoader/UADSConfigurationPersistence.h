#import <Foundation/Foundation.h>
#import "USRVConfiguration.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSConfigurationSaver <NSObject>

- (void)saveConfiguration: (USRVConfiguration *)configuration;

@end

@interface UADSConfigurationPersistence : NSObject<UADSConfigurationSaver>
+ (instancetype)newWithTokenCRUD: (id<UADSHeaderBiddingTokenCRUD>)crud;
@end

NS_ASSUME_NONNULL_END
