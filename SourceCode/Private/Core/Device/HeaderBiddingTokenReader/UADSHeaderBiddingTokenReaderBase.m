#import "UADSHeaderBiddingTokenReaderBase.h"

@interface UADSHeaderBiddingTokenReaderBase ()
@property (nonatomic, strong) id<UADSDeviceInfoReader> deviceInfoReader;
@property (nonatomic, strong) id<USRVStringCompressor> compressor;
@end

@implementation UADSHeaderBiddingTokenReaderBase

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                          andCompressor: (id<USRVStringCompressor>)compressor {
    UADSHeaderBiddingTokenReaderBase *base = [self new];

    base.deviceInfoReader = deviceInfoReader;
    base.compressor = compressor;
    return base;
}

- (void)getToken: (UADSHeaderBiddingTokenCompletion)completion {
    NSDictionary *info = [_deviceInfoReader getDeviceInfoForGameMode: UADSGameModeMix];
    NSString *token = [_compressor compressedIntoString: info];

    completion([@"1:" stringByAppendingString: token], kUADSTokenNative);
}

@end
