#import <Foundation/Foundation.h>
#import "USRVConfiguration.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"

NS_ASSUME_NONNULL_BEGIN


@interface UADSConfigurationSaverWithTokenStorage : NSObject<UADSConfigurationSaver>
+ (instancetype)newWithTokenCRUD: (id<UADSHeaderBiddingTokenCRUD>)crud
                     andOriginal: (id<UADSConfigurationSaver>)original;
@end

NS_ASSUME_NONNULL_END
