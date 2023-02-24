#import <Foundation/Foundation.h>
#import "UADSGMAScar.h"
#import "USRVWebRequestFactory.h"
#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy : NSObject<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original config:(UADSHeaderBiddingTokenReaderSCARSignalsConfig*)config;

@end

NS_ASSUME_NONNULL_END
