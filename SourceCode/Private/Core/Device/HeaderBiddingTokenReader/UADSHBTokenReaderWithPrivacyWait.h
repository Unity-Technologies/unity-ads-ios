#import <Foundation/Foundation.h>
#import "UADSHeaderBiddingTokenReaderBase.h"
#import "UADSPrivacyStorage.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSHBTokenReaderWithPrivacyWait : NSObject<UADSHeaderBiddingAsyncTokenReader>

+ (instancetype)newWithOriginal: (id<UADSHeaderBiddingAsyncTokenReader>)original
              andPrivacySubject: (id<UADSPrivacyResponseSubject, UADSPrivacyResponseReader>)subject
                        timeout: (NSInteger)timeoutInSeconds;
@end

NS_ASSUME_NONNULL_END
