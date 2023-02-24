#ifndef UADSSCARHeaderBiddingBaseStrategy_Internal_h
#define UADSSCARHeaderBiddingBaseStrategy_Internal_h
#import "UADSSCARSignalReader.h"
#import "UADSSCARSignalSender.h"

@interface UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy ()

@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> _Nonnull original;
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderSCARSignalsConfig* _Nonnull config;
@property (nonatomic, strong) id<UADSSCARSignalReader> _Nullable scarSignalReader;
@property (nonatomic, strong) id<UADSSCARSignalSender> _Nullable scarSignalSender;


- (UADSHeaderBiddingToken*_Nonnull) setUUIDString:(NSString*_Nonnull)uuidString ifRemoteToken:(UADSHeaderBiddingToken*_Nonnull)token;

@end


#endif /* UADSSCARHeaderBiddingBaseStrategy_Internal_h */
