#import "UADSAbstractModuleOperationBasicObject.h"

@interface UADSAbstractModuleOperationBasicObject()
@property (nonatomic, copy) NSString *id;
@property (nonatomic, strong) UADSVoidClosure operationExpired;
@property (nonatomic) dispatch_block_t dispatchBlock;
@end

@implementation UADSAbstractModuleOperationBasicObject


- (instancetype)init {
    SUPER_INIT;
    self.id = [NSUUID new].UUIDString;
    return self;
}

- (nonnull NSDictionary *)dictionary {
    return @{
        kUADSOptionsDictionaryKey: @{
                kUADSHeaderBiddingOptionsDictionaryKey: self.options.dictionary
        },
        kUADSTimestampKey: self.time,
        kUADSPlacementIDKey: self.placementID,
        kUADSListenerIDKey: self.id
    };
}

- (nonnull NSString *)methodName {
    NSAssert(NO, @"Cannot use abstract class");
    return nil;
}

- (void)startListeningOperationTTLExpiration:(UADSVoidClosure)operationExpired {
    _operationExpired = operationExpired;
    if (_ttl >= 0) {
        [self startTimer];
    }
}

-(void)startTimer {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _ttl * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf signalExpiration];
    });
}

- (void)signalExpiration {
    if (_operationExpired) {
        _operationExpired();
    }
}

- (void)stopTTLObserving {
    _operationExpired = nil;
}

- (void)dealloc {
    [self stopTTLObserving];
}


@end
