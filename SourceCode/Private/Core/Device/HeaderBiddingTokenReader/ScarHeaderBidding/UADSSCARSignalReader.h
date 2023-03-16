#ifndef UADSSCARSignalReader_h
#define UADSSCARSignalReader_h

#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"

@protocol UADSSCARSignalReader <NSObject>

- (void) requestSCARSignalsWithIsAsync:(BOOL)isAsync completion: (_Nullable UADSSuccessCompletion) completion;

@end

#endif /* UADSSCARSignalReader_h */
