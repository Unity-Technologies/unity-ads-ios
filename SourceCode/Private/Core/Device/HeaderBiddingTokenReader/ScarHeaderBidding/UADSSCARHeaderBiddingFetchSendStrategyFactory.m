#import "UADSSCARHeaderBiddingFetchSendStrategyFactory.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsHybridStrategy.h"

@implementation UADSSCARHeaderBiddingFetchSendStrategyFactory

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>) strategyWithOriginal:(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original {
    
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> strategy = original;
    switch (self.config.configurationReader.selectedSCARHBStrategyType) {
        case UADSSCARHeaderBiddingStrategyTypeEager:
            strategy = [UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy decorateOriginal:original config:self.config];
            break;
        case UADSSCARHeaderBiddingStrategyTypeLazy:
            strategy = [UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy decorateOriginal:original config:self.config];
            break;
        case UADSSCARHeaderBiddingStrategyTypeHybrid:
            strategy = [UADSHeaderBiddingTokenReaderWithSCARSignalsHybridStrategy decorateOriginal:original config:self.config];
            break;
        case UADSSCARHeaderBiddingStrategyTypeDisabled:
        default:
            break;
    }
    return strategy;
}
@end
