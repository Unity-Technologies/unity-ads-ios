#ifndef UADSSCARSignalReader_h
#define UADSSCARSignalReader_h

#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"

@protocol UADSSCARSignalReader <NSObject>

- (void) requestSCARSignalsWithCompletion: (_Nullable UADSSuccessCompletion) completion;

@end

#endif /* UADSSCARSignalReader_h */
