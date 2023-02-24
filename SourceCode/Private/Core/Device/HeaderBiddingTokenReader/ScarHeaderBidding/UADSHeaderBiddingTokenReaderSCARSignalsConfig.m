#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"
#import "UADSSCARHeaderBiddingFetchSendStrategyFactory.h"
#import "UADSSCARHeaderBiddingStrategyFactory.h"

@implementation UADSHeaderBiddingTokenReaderSCARSignalsConfig

-(instancetype) init {
    SUPER_INIT;
    UADSSCARHeaderBiddingFetchSendStrategyFactory* strategyFactory = [UADSSCARHeaderBiddingFetchSendStrategyFactory new];
    strategyFactory.config = self;
    self.strategyFactory = strategyFactory;
    self.idfiReader = [UADSDeviceIDFIReaderBase new];
    self.timestampReader = [UADSCurrentTimestampBase new];
    
    return self;
}

@end
