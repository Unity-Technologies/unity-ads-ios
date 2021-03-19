#import "UADSWebViewInvokerMock.h"
#import "UADSTools.h"

@interface UADSWebViewInvokerMock()
@property (nonatomic, strong) NSArray<UADSWebViewInvokerCompletion>*completions;
@property (nonatomic, strong) NSArray<UADSWebViewInvokerErrorCompletion>*errorCompletions;
@property (nonatomic, strong) NSArray<id<UADSWebViewInvokerOperation>>*operations;
@end

@implementation UADSWebViewInvokerMock

- (instancetype)init {
    SUPER_INIT
    self.completions = [NSArray new];
    self.errorCompletions = [NSArray new];
    self.operations = [NSArray new];
    return self;
}

- (void)invokeOperation:(id<UADSWebViewInvokerOperation>)operation
         withCompletion:(UADSWebViewInvokerCompletion)completion
     andErrorCompletion:(UADSWebViewInvokerErrorCompletion)errorCompletion {
    _completions = [_completions arrayByAddingObject: completion];
    _errorCompletions = [_errorCompletions arrayByAddingObject: errorCompletion];
    _operations = [_operations arrayByAddingObject: operation];
    [self.expectation fulfill];
}



- (void)emulateCallSuccess {
    [_completions enumerateObjectsUsingBlock:^(UADSWebViewInvokerCompletion  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj();
    }];
}

- (void)emulateCallFailWithError:(UADSInternalError *)error {
    [_errorCompletions enumerateObjectsUsingBlock:^(UADSWebViewInvokerErrorCompletion  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj(error);
    }];
}

- (NSInteger)invokerCalledNumberOfTimes {
    return _operations.count;
}

@end
