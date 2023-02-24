#import <Foundation/Foundation.h>
#import "UADSSCARSignalSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSSCARWebRequestSignalSender : NSObject <UADSSCARSignalSender>

@property (nonatomic, weak) UADSHeaderBiddingTokenReaderSCARSignalsConfig* config;

@end

NS_ASSUME_NONNULL_END
