#import "UADSFactoryConfigMock.h"

@implementation UADSFactoryConfigMock
- (NSString *)gameID {
    if (_gameID) {
        return _gameID;
    }

    return @"GameID";
}

- (NSString *)sdkVersionName {
    if (_sdkVersionName) {
        return _sdkVersionName;
    }

    return @"SDKVersionName";
}

- (NSNumber *)sdkVersion {
    if (_sdkVersion) {
        return _sdkVersion;
    }

    return @(4000);
}

@end
