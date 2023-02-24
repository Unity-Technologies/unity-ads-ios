#ifndef UADSSCARHeaderBiddingStrategyFactory_h
#define UADSSCARHeaderBiddingStrategyFactory_h

#import "UADSGMAScar.h"
#import "USRVWebRequestFactory.h"
#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"
#import "UADSSCARHBStrategyType.h"


@protocol UADSSCARHeaderBiddingStrategyFactory <NSObject>

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> _Nonnull) strategyWithOriginal:(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>_Nonnull)original;

@end

#endif /* UADSSCARHeaderBiddingStrategyFactory_h */
