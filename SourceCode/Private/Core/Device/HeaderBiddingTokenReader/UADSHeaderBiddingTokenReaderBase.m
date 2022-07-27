#import "UADSHeaderBiddingTokenReaderBase.h"

@interface UADSHeaderBiddingTokenReaderBase ()
@property (nonatomic, strong) id<UADSDeviceInfoReader> deviceInfoReader;
@property (nonatomic, strong) id<USRVStringCompressor> compressor;
@property (nonnull, copy) NSString *customPrefix;
@end

@implementation UADSHeaderBiddingTokenReaderBase

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                          andCompressor: (id<USRVStringCompressor>)compressor
                        withTokenPrefix: (NSString *)prefix {
    UADSHeaderBiddingTokenReaderBase *base = [self new];

    base.deviceInfoReader = deviceInfoReader;
    base.compressor = compressor;
    base.customPrefix = prefix;
    return base;
}

- (void)getToken: (UADSHeaderBiddingTokenCompletion)completion {
    NSDictionary *info = [_deviceInfoReader getDeviceInfoForGameMode: UADSGameModeMix];
    NSString *token = [_compressor compressedIntoString: info];

    NSString *value = [self.customPrefix stringByAppendingString: token];
    UADSHeaderBiddingToken *hbToken = [UADSHeaderBiddingToken newNative: value];

    completion(hbToken);
}

@end
