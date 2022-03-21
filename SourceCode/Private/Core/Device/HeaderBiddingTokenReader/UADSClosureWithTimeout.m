#import "UADSClosureWithTimeout.h"
#import "UADSTools.h"
typedef void (^UADSClosureWithTimeoutBlock)(id, UADSTokenType);

@interface UADSClosureWithTimeout ()
@property (nonatomic, strong) UADSClosureWithTimeoutBlock block;
@property (nonatomic, strong) UADSTimeoutBlock timeoutBlock;
@property (nonatomic) NSUUID *id;
@property (nonatomic) UADSTokenType type;
@end

@implementation UADSClosureWithTimeout

+ (instancetype)newWithType: (UADSTokenType)type
           timeoutInSeconds: (NSInteger)timeout
          andTimeoutClosure: (UADSTimeoutBlock)timeoutBlock
                   andBlock: (void (^)(id _Nullable, UADSTokenType))block {
    UADSClosureWithTimeout *wrapper = [self new];

    wrapper.type = type;
    wrapper.block = block;
    wrapper.timeoutBlock = timeoutBlock;
    wrapper.id = [NSUUID new];
    __block typeof(wrapper) weakWrapper = wrapper;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (long long)timeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakWrapper didTimeout];
    });

    return wrapper;
}

- (void)didTimeout {
    if (_timeoutBlock) {
        _timeoutBlock(_id, _type);
    }

    [self invalidateTimeout];
}

- (void)callClosureWith: (id _Nullable)object {
    [self invalidateTimeout];

    if (self.block) {
        _block(object, _type);
    }
}

- (void)invalidateTimeout {
    _timeoutBlock = nil;
}

@end
