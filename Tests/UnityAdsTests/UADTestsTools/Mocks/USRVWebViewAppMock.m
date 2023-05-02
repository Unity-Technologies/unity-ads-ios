#import "USRVWebViewAppMock.h"
#import "UADSTools.h"
#import "NSInvocation+Convenience.h"
#import "USRVInvocation.h"
@interface USRVWebViewAppMock ()
@property (nonatomic, strong) NSArray<NSString *> *methodNames;
@property (nonatomic, strong) NSArray<NSString *> *classNames;
@property (nonatomic, strong) NSArray<NSString *> *receiverClasses;
@property (nonatomic, strong) NSArray<NSString *> *callbacks;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation USRVWebViewAppMock



- (instancetype)init
{
    SUPER_INIT;
    self.methodNames = [NSArray new];
    self.classNames = [NSArray new];
    self.receiverClasses = [NSArray new];
    self.callbacks = [NSArray new];
    self.returnedParams = [NSArray new];
    self.categoryNames = [NSArray new];
    self.eventNames = [NSArray new];
    self.params = [NSArray new];
    self.serialQueue = dispatch_queue_create("USRVWebViewAppMock.Queue", DISPATCH_QUEUE_SERIAL);
    self.expectedNumberOfCalls = @1;
    return self;
}

- (BOOL)sendEvent: (NSString *)eventId category: (NSString *)category param1: (id)param1, ... {
    _categoryNames = [_categoryNames arrayByAddingObject: category];
    _eventNames = [_eventNames arrayByAddingObject: eventId];
    if (param1) {
        _params =  [_params arrayByAddingObject: param1];
    }
    
    return true;
}

- (BOOL)sendEvent: (NSString *)eventId category: (NSString *)category params: (NSArray *)params {
    [_expectation fulfill];
    _categoryNames = [_categoryNames arrayByAddingObject: category];
    _eventNames = [_eventNames arrayByAddingObject: eventId];

    if (params) {
        _params =  [_params arrayByAddingObject: params];
    }

    return true;
}

- (BOOL)invokeMethod: (NSString *)methodName
           className: (NSString *)className
       receiverClass: (NSString *)receiverClass
            callback: (NSString *)callback
              params: (NSArray *)params {
    dispatch_sync(_serialQueue, ^{
        self.methodNames = [self.methodNames arrayByAddingObject: methodName];
        self.classNames = [self.classNames arrayByAddingObject: className];
        self.receiverClasses = [self.receiverClasses arrayByAddingObject: receiverClass];
        self.callbacks = [self.callbacks arrayByAddingObject: callback];
        self.returnedParams = [self.returnedParams arrayByAddingObject: params];

        if (self.expectedNumberOfCalls.integerValue == _methodNames.count) {
            [self.expectation fulfill];
        }
    });

    return true;
}

- (void)installAllowedClasses: (NSArray *)allowedClasses {
    [USRVInvocation setClassTable: allowedClasses];
}

- (void)emulateResponseWithParams: (NSArray *)params {
    [self emulateResponseWithParams: params
                    operationNumber: -1];
}

- (void)emulateResponseWithParams: (NSArray *)params
                  operationNumber: (int)index {
    if (index >= 0) {
        [self emulateInvokeMethod: _methodNames[index]
                        className: _classNames[index]
                    receiverClass: _receiverClasses[index]
                         callback: _callbacks[index]
                           params: params];
    } else {
        for (int i = 0; i < _methodNames.count; i++) {
            [self emulateInvokeMethod: _methodNames[i]
                            className: _classNames[i]
                        receiverClass: _receiverClasses[i]
                             callback: _callbacks[i]
                               params: params];
        }
    }
}

- (void)emulateInvokeMethod: (NSString *)methodName
                  className: (NSString *)className
              receiverClass: (NSString *)receiverClass
                   callback: (NSString *)callback
                     params: (NSArray *)params {
    Class targetClass = NSClassFromString(receiverClass);

    [NSInvocation uads_invokeUsingMethod: callback
                               classType: targetClass
                                  target: nil
                                    args: @[params]];
}

- (void)emulateInvokeWebExposedMethod: (NSString *)methodName
                            className: (NSString *)className
                               params: (NSArray *)params
                             callback: (id)callback {
    USRVInvocation *invocation = [USRVInvocation new];

    [invocation addInvocation: className
                   methodName: methodName
                   parameters: params
                     callback: callback];
    [invocation nextInvocation];
}

@end
