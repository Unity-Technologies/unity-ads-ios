#import <Foundation/Foundation.h>
#import "UADSSCARSignalReader.h"

#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSSCARRawSignalsReader : NSObject <UADSSCARSignalReader>

@property (nonatomic, weak) UADSHeaderBiddingTokenReaderSCARSignalsConfig* config;

@end

NS_ASSUME_NONNULL_END
