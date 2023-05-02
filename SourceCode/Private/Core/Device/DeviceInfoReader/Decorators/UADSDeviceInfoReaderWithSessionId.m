#import "UADSDeviceInfoReaderWithSessionId.h"
#import "UADSDeviceInfoReaderKeys.h"

@interface UADSDeviceInfoReaderWithSessionId()
@property (nonatomic, strong) id<UADSDeviceInfoReader> original;
@property (nonatomic, strong) id<UADSSharedSessionIdReader> sessionIdReader;
@end

@implementation UADSDeviceInfoReaderWithSessionId

+ (id<UADSDeviceInfoReader>)newWithOriginal: (id<UADSDeviceInfoReader>)original
                         andSessionIdReader: (id<UADSSharedSessionIdReader>)sessionIdReader {
    UADSDeviceInfoReaderWithSessionId *reader = [UADSDeviceInfoReaderWithSessionId new];
    reader.original = original;
    reader.sessionIdReader = sessionIdReader;
    return reader;
}

- (NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSDictionary *info = [_original getDeviceInfoForGameMode: mode];
    
    NSMutableDictionary *mInfo = [[NSMutableDictionary alloc] initWithDictionary: info];
    mInfo[kUADSDeviceInfoSessionIdKey] = _sessionIdReader.sessionId;
    
    return mInfo;
}

@end
