#import "UADSJsonStorageReaderMock.h"
#import "UADSTools.h"


@implementation UADSJsonStorageReaderMock


- (instancetype)init {
    SUPER_INIT;
    self.getContentCount = 0;
    self.requestedKeys = @[];
    return self;
}

- (NSDictionary *)getContents {
    _getContentCount += 1;

    if (_original) {
        return [_original getContents];
    }

    return self.expectedContent;
}

- (id)getValueForKey: (NSString *)key {
    _requestedKeys = [_requestedKeys arrayByAddingObjectsFromArray: @[key]];

    if (_original) {
        return [_original getValueForKey: key];
    }

    return [_expectedContent valueForKey: key];
}

@end
