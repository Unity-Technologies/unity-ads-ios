#import "UADSNullInitializedMock.h"

@implementation UADSNullInitializedMock

- (instancetype)init {
    return nil;
}

@end

@implementation UADSNullInitializedReflectionMock

+ (NSString *)className {
    return @"UADSNullInitializedMock";
}

@end


@interface UADSNSObjectDeallocationCheck : NSObject

@end

@implementation UADSNSObjectDeallocationCheck
static NSInteger _uADSNSObjectDeallocationCount = 0;

- (instancetype)init {
    self = [super init];

    if (self) {
        _uADSNSObjectDeallocationCount = 0;
    }

    return self;
}

- (void)dealloc {
    _uADSNSObjectDeallocationCount++;
}

@end

@implementation UADSNSObjectReflectionMock

+ (NSNumber *)proxyDeallocationCount {
    return @(_uADSNSObjectDeallocationCount);
}

+ (NSString *)className {
    return @"UADSNSObjectDeallocationCheck";
}

@end
