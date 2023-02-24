#import "UADSHeaderBiddingTokenReaderBase.h"

@interface UADSHeaderBiddingTokenReaderBase ()
@property (nonatomic, strong) id<UADSDeviceInfoReader> deviceInfoReader;
@property (nonatomic, strong) id<USRVStringCompressor> compressor;
@property (nonnull, copy) NSString *customPrefix;
@property (nonatomic) id<UADSUniqueIdGenerator> uniqueIdGenerator;
@end

@implementation UADSHeaderBiddingTokenReaderBase

+ (instancetype)newWithDeviceInfoReader: (id<UADSDeviceInfoReader>)deviceInfoReader
                          andCompressor: (id<USRVStringCompressor>)compressor
                        withTokenPrefix: (NSString *)prefix
                  withUniqueIdGenerator: (id<UADSUniqueIdGenerator>) uniqueIdGenerator {
    UADSHeaderBiddingTokenReaderBase *base = [self new];

    base.deviceInfoReader = deviceInfoReader;
    base.compressor = compressor;
    base.customPrefix = prefix;
    base.uniqueIdGenerator = uniqueIdGenerator;
    return base;
}
    
- (void)getToken:(UADSHeaderBiddingTokenCompletion)completion {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[_deviceInfoReader getDeviceInfoForGameMode: UADSGameModeMix]];
    NSString* uniqueId = [self.uniqueIdGenerator generateId];
    info[@"tid"] = uniqueId;
    NSString *tokenValue = [_compressor compressedIntoString: info];
    NSString *prefixedTokenValue = [self.customPrefix stringByAppendingString: tokenValue];
    UADSHeaderBiddingToken *hbToken = [UADSHeaderBiddingToken newNative:prefixedTokenValue];
    hbToken.customPrefix = _customPrefix;
    hbToken.uuidString = uniqueId;
    hbToken.info = info;//this will set the uuid
    
    completion(hbToken);
}

@end
