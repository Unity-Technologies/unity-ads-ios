#import "UADSGenericClosureWrapper.h"

@interface UADSGenericClosureWrapper ()
@property (nonatomic, strong) UADSGenericClosure closure;
@property (nonatomic, strong) UADSIDBlock timeoutBlock;
@property (nonatomic, strong) NSUUID *uuid;
@end

@implementation UADSGenericClosureWrapper

+ (instancetype)newWithClosure: (UADSGenericClosure)closure {
    UADSGenericClosureWrapper *wrapper = [UADSGenericClosureWrapper new];

    wrapper.uuid = [NSUUID new];
    wrapper.closure = closure;
    return wrapper;
}

+ (instancetype)newWithTimeoutInSeconds: (NSInteger)timeout
                      andTimeoutClosure: (UADSIDBlock)timeoutBlock
                               andBlock: (UADSGenericClosure)block {
    UADSGenericClosureWrapper *wrapper = [self newWithClosure: block];

    wrapper.timeoutBlock = timeoutBlock;
    __block typeof(wrapper) weakWrapper = wrapper;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (long long)timeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakWrapper didTimeout];
    });
    return wrapper;
}

- (void)callWithObject: (id)obj {
    [self invalidateTimeout];

    if (_closure) {
        _closure(obj);
    }
}

- (void)invalidateTimeout {
    _timeoutBlock = nil;
}

- (void)didTimeout {
    if (_timeoutBlock) {
        _timeoutBlock(_uuid);
    }

    [self invalidateTimeout];
}

@end
