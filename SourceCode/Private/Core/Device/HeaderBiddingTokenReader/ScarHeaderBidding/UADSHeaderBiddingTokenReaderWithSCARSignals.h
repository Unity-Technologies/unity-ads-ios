#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderWithSCARSignals : NSObject<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original withConfig:(UADSHeaderBiddingTokenReaderSCARSignalsConfig*)config;

@end

NS_ASSUME_NONNULL_END
