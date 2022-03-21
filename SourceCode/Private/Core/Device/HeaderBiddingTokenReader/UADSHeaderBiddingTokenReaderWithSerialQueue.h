#import "UADSInitializationStatusReader.h"
#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderWithSerialQueue : NSObject<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>
+ (instancetype)newWithOriginalReader: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original
                      andStatusReader: (id<UADSInitializationStatusReader>)statusReader;
@end

NS_ASSUME_NONNULL_END
