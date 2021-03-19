#import "USRVWebViewAppMock.h"
#import "UADSTools.h"
#import "NSInvocation+Convenience.h"
@interface USRVWebViewAppMock()
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
    self.serialQueue = dispatch_queue_create("USRVWebViewAppMock.Queue", DISPATCH_QUEUE_SERIAL);
    self.expectedNumberOfCalls = @1;
    return self;
}


- (BOOL)invokeMethod:(NSString *)methodName
           className:(NSString *)className
       receiverClass:(NSString *)receiverClass
            callback:(NSString *)callback
              params:(NSArray *)params {
    
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

-(void)emulateResponseWithParams: (NSArray *)params {
    [self emulateResponseWithParams: params operationNumber: -1];
}

-(void)emulateResponseWithParams: (NSArray *)params
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




- (void)emulateInvokeMethod:(NSString *)methodName
                  className:(NSString *)className
              receiverClass:(NSString *)receiverClass
                   callback:(NSString *)callback
                     params:(NSArray *)params {
    
    Class targetClass = NSClassFromString(receiverClass);
    [NSInvocation uads_invokeUsingMethod: callback
                               classType: targetClass
                                  target: nil
                                    args: @[params]];
}

@end
