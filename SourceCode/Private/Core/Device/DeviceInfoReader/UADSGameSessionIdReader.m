#import "UADSGameSessionIdReader.h"
#import "USRVStorageManager.h"
#import "USRVDevice.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSGameSessionIdReaderBase ()
@property (nonatomic, strong) NSNumber *gameSessionId;
@end

@implementation UADSGameSessionIdReaderBase

- (nonnull NSNumber *)gameSessionId {
    @synchronized (self) {
        [self generateSessionIdIfNeeded];
    }
    return _gameSessionId;
}

- (void)generateSessionIdIfNeeded {
    if (_gameSessionId != nil) {
        return;
    }
    
    NSString *uuidString = [[[USRVDevice getUniqueEventId] stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:12];
    long long hex = strtoull([uuidString UTF8String], NULL, 16);
    _gameSessionId = [NSNumber numberWithLongLong:hex];
    
    [[USRVStorageManager getStorage: kUnityServicesStorageTypePrivate] set: UADSJsonStorageKeyNames.webViewDataGameSessionIdKey
                                                                     value: _gameSessionId];
}

@end
