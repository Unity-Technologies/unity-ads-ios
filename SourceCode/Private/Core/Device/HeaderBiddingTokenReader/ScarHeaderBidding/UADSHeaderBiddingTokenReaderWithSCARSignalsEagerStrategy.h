#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy.h"
#import "UADSUniqueIdGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy : UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy

@property (nonatomic) id<UADSUniqueIdGenerator> uniqueIdGenerator;

- (UADSHeaderBiddingToken *) regenerateTokenValueWithUUIDString:(NSString*) uuidString token:(UADSHeaderBiddingToken *) token;

@end

NS_ASSUME_NONNULL_END
