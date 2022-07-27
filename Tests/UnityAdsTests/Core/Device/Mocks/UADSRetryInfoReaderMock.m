
#import "UADSRetryInfoReaderMock.h"

@interface UADSRetryInfoReaderMock ()
@property (nonatomic, strong) NSDictionary *info;
@end

@implementation UADSRetryInfoReaderMock

+ (instancetype)newWithInfo: (NSDictionary *)info {
    UADSRetryInfoReaderMock *mock = [UADSRetryInfoReaderMock new];

    mock.info = info;
    return mock;
}

- (NSDictionary *)retryTags {
    return _info;
}

@end
