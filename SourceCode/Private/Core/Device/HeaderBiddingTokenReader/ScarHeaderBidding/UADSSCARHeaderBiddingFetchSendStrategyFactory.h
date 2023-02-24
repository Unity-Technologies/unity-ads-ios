#import <Foundation/Foundation.h>
#import "UADSSCARHeaderBiddingStrategyFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSSCARHeaderBiddingFetchSendStrategyFactory : NSObject <UADSSCARHeaderBiddingStrategyFactory>

@property (nonatomic, weak) UADSHeaderBiddingTokenReaderSCARSignalsConfig* config;

@end

NS_ASSUME_NONNULL_END
