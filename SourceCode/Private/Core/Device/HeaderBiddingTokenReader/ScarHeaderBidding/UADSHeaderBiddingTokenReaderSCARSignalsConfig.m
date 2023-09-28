#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"

@implementation UADSHeaderBiddingTokenReaderSCARSignalsConfig

-(instancetype) init {
    SUPER_INIT;
    self.idfiReader = [UADSDeviceIDFIReaderBase new];
    self.timestampReader = [UADSCurrentTimestampBase new];
    
    return self;
}

@end
