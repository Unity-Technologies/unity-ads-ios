#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "USRVBodyBase64GzipCompressor.h"
#import "UADSTokenType.h"
#import "UADSHeaderBiddingToken.h"
#import "UADSConfigurationCRUDBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSHeaderBiddingTokenCompletion)(UADSHeaderBiddingToken *_Nullable token);

@protocol UADSHeaderBiddingAsyncTokenReader <NSObject>

- (void)getToken: (UADSHeaderBiddingTokenCompletion)completion;

@end

@interface UADSHeaderBiddingTokenReaderBase : NSObject<UADSHeaderBiddingAsyncTokenReader>

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                          andCompressor: (id<USRVStringCompressor>)compressor
                        withTokenPrefix: (NSString *)prefix
                  withUniqueIdGenerator: (id<UADSUniqueIdGenerator>) uniqueIdGenerator
                withConfigurationReader: (id<UADSConfigurationReader>) configurationReader;

@end

NS_ASSUME_NONNULL_END
