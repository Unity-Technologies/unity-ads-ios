#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderBase.h"
#import "UADSTokenStorage.h"
#import "UADSConfigurationReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderBridge : NSObject<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>

+ (instancetype)newWithNativeTokenGenerator: (id<UADSHeaderBiddingAsyncTokenReader>)nativeTokenGenerator
                               andTokenCRUD: (id<UADSHeaderBiddingTokenCRUD>)tokenCRUD
                     andConfigurationReader: (id<UADSConfigurationReader>)configurationReader;
@end

NS_ASSUME_NONNULL_END
