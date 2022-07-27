#import "UADSAbstractTestModule.h"

@interface UADSAbstractTestModuleState ()
@property (nonatomic, strong) UADSVoidClosure operationExpired;
@end

@implementation UADSAbstractTestModuleState
- (nonnull NSDictionary *)dictionary {
    return @{ @"listenerID": _id };
}

- (nonnull NSString *)methodName {
    return @"FAKE_METHOD";
}

- (void)startListeningOperationTTLExpiration: (UADSVoidClosure)operationExpired {
    self.operationExpired = operationExpired;
}

- (void)emulateExpired {
    _operationExpired();
}

@end

@implementation UADSAbstractTestModule
static NSInteger createCalled = 0;


+ (instancetype)sharedInstance {
    UADS_SHARED_INSTANCE(onceToken, ^{
        return [self newSharedModule];
    });
}

+ (instancetype)createDefaultModule {
    createCalled++;
    return [self new];
}

+ (NSInteger)numberOfCreateCalls {
    return createCalled;
}

- (id<UADSAbstractModuleOperationObject>)createEventWithPlacementID: (NSString *)placementID
                                                        withOptions: (id<UADSDictionaryConvertible>)options
                                                              timer: (id<UADSRepeatableTimer>)timer
                                                       withDelegate: (id<UADSAbstractModuleDelegate>)delegate {
    return _returnedState;
}

- (UADSInternalError *)executionErrorForPlacementID: (NSString *)placementID {
    return _returnedExecutionError;
}

- (NSInteger)operationOperationTimeoutMs {
    return 1;
}

@end
