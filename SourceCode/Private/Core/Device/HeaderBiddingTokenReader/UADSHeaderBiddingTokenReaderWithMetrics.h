#import <Foundation/Foundation.h>
#import "UADSTokenStorage.h"
#import "UADSHeaderBiddingTokenReaderBase.h"
#import "USRVSDKMetrics.h"
#import "UADSInitializationStatusReader.h"
#import "UADSPrivacyStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderWithMetrics : NSObject<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original
                 andStatusReader: (id<UADSInitializationStatusReader>)statusReader
                   metricsSender: (id<ISDKMetrics>)metricsSender
           privacyResponseReader: (id<UADSPrivacyResponseReader>)privacyResponseReader;

@end

NS_ASSUME_NONNULL_END
