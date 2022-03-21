#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "USRVBodyBase64GzipCompressor.h"
#import "UADSTokenType.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSHeaderBiddingTokenCompletion)(NSString *_Nullable token, UADSTokenType type);

@protocol UADSHeaderBiddingAsyncTokenReader <NSObject>

- (void)getToken: (UADSHeaderBiddingTokenCompletion)completion;

@end

@interface UADSHeaderBiddingTokenReaderBase : NSObject<UADSHeaderBiddingAsyncTokenReader>

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                          andCompressor: (id<USRVStringCompressor>)compressor;

@end

NS_ASSUME_NONNULL_END
