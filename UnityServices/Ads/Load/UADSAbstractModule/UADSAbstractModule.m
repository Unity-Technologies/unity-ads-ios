#import "UADSAbstractModule.h"
#import "USRVConfiguration.h"
#import "NSMutableDictionary + SafeRemoval.h"

static NSString * const kUADSOperationExpirationMessage = @"%@ method timeout after %li for listener ID %@";
static NSString * const kUADSAbstractModuleErrorMessage = @"UADSAbstractModule cannot continue with the empty placement ID";
static NSString * const kUADSAbstractModuleEmptyPlacementID = @"";

static USRVConfiguration *configuration = nil;

@interface UADSAbstractModule()
@property(nonatomic, strong) NSMutableDictionary<NSString*, id<UADSAbstractModuleOperationObject>> *stateStorage;
@property(nonatomic, strong) dispatch_queue_t synchronizedQueue;
@property(nonatomic, strong) dispatch_queue_t invokeQueue;
@property(nonatomic, strong) id<UADSWebViewInvoker> invoker;
@property(nonatomic, strong) id<UADSErrorHandler> errorHandler;
@end

@implementation UADSAbstractModule

+ (instancetype)newWithInvoker:(id<UADSWebViewInvoker>)invoker
               andErrorHandler:(id<UADSErrorHandler>)errorHandler {
    UADSAbstractModule *module = [self new];
    module.invoker = invoker;
    module.errorHandler = errorHandler;
    return module;
}

+ (instancetype)sharedInstance {
    UADS_SHARED_INSTANCE(onceToken, ^{
        return [self newSharedModule];
    });
}

+(instancetype)newSharedModule {
    [self setDefaultConfigurationIfNeed];
    return [self createDefaultModule];
}

+(void)setDefaultConfigurationIfNeed {
    if (configuration == nil) {
        configuration = [[USRVConfiguration alloc] init];
        USRVLogError(@"Configuration is null, apply default configuration");
    }
}


+(instancetype)createDefaultModule {
    NSAssert(NO, @"Cannot use abstract class");
    return nil;
}

+ (USRVConfiguration *)configuration {
    return configuration;
}
-(instancetype)init {
    SUPER_INIT;
    _synchronizedQueue = dispatch_queue_create("com.unity3d.abstract.module", DISPATCH_QUEUE_SERIAL);
    _invokeQueue =  dispatch_queue_create("com.unity3d.ads.abstract.module.invoke", DISPATCH_QUEUE_SERIAL);
    _stateStorage = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)executeForPlacement:(NSString *)placementId
                withOptions:(id<UADSDictionaryConvertible>)options
                andDelegate:(id<UADSAbstractModuleDelegate>)delegate
          forViewController:(UIViewController *)viewController {
    
    NSString *safePlacementID = placementId ?: kUADSAbstractModuleEmptyPlacementID;
    
    UADSInternalError *error = [self executionErrorForPlacementID: safePlacementID];
    
    if (error) {
        [self logErrorAndNotifyDelegate: delegate
                            errorParams: error
                         forPlacementID: safePlacementID];
        return;
    }
    
    id<UADSAbstractModuleOperationObject> operation =  [self createEventWithPlacementID: safePlacementID
                                                                            withOptions: options
                                                                           withDelegate: delegate
                                                                      andViewController: viewController];
    
    [self saveOperation: operation];
    

    dispatch_async(_invokeQueue, ^{
        [self invokeOperation: operation];
    });
}


-(NSInteger)operationOperationTimeoutMs {
    return -1;
}

-(UADSInternalError * _Nullable)executionErrorForPlacementID: (NSString *)placementID {
    BOOL cannotExecute = placementID == nil || [placementID isEqual: kUADSAbstractModuleEmptyPlacementID];
    GUARD_OR_NIL(cannotExecute);
    
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorAbstractModule
                                     andReason: kUADSInternalErrorAbstractModuleEmptyPlacementID
                                    andMessage: kUADSAbstractModuleErrorMessage];
}

-(id<UADSAbstractModuleOperationObject>)createEventWithPlacementID: (NSString *)placementID
                                                       withOptions: (id<UADSDictionaryConvertible>)options
                                                      withDelegate: (id<UADSAbstractModuleDelegate>)delegate
                                                 andViewController: (UIViewController *)viewController {
    
    NSAssert(NO, @"Cannot use abstract class");
    return nil;
}

-(void)logErrorAndNotifyDelegate: (id<UADSAbstractModuleDelegate>)delegate
                     errorParams: (UADSInternalError *)error
                  forPlacementID: (NSString *)placementID {
    [_errorHandler catchError: error];
    [delegate didFailWithError: error
                forPlacementID: placementID];
}

-(void)saveOperation: (id<UADSAbstractModuleOperationObject>)operation {
    
    dispatch_sync(_synchronizedQueue, ^{
        [self.stateStorage setObject: operation forKey: operation.id];
    });
}

-(void)invokeOperation: (id<UADSAbstractModuleOperationObject>)operation {
    if ([self operationOperationTimeoutMs] >= 0) {
        [self subscribeToOperationExpiration: operation];
    }
    [self callInvokerWithOperation: operation];
}


-(void)subscribeToOperationExpiration: (id<UADSAbstractModuleOperationObject>)operation {
    __weak typeof(self) weakSelf = self;
    __weak typeof(operation) weakOperation = operation;
    [operation startListeningOperationTTLExpiration:^{
        if (weakOperation) {
            [weakSelf processOperationExpiration: weakOperation];
        }
    }];
}


-(void)processOperationExpiration: (id<UADSAbstractModuleOperationObject>)operation {
    UADSInternalError* error = [self expirationErrorOfOperation: operation];
    [self processError: error forOperation:operation];
}

-(void)callInvokerWithOperation:(id<UADSAbstractModuleOperationObject>)operation {
    __weak typeof(self) weakSelf = self;
    
    [_invoker invokeOperation: operation
               withCompletion: ^{
        [weakSelf processInvokerSuccess];
    }
            andErrorCompletion: ^(UADSInternalError * _Nullable error) {
        
        [weakSelf processError: error forOperation: operation];
    }];
}

-(void)processError: (UADSInternalError * _Nullable) error
       forOperation: (id<UADSAbstractModuleOperationObject>)operation {
    GUARD(error)
    [self notifyDelegateWithInternalError: error
                           forOperationID: operation.id];
    [self removeOperationFromTemporaryStorage: operation.id];
}

-(void)processInvokerSuccess {
    
}

-(void)notifyDelegateWithInternalError: (UADSInternalError * _Nullable) error
                        forOperationID: (NSString *)operationID {
    
    id<UADSAbstractModuleOperationObject> operation = [self getOperationWithID: operationID];
    GUARD(operation);
    [_errorHandler catchError: error];
    [operation.delegate didFailWithError: error
                          forPlacementID: operation.placementID];
}

-(void)removeOperationFromTemporaryStorage: (NSString *)operationID {
    dispatch_sync(_synchronizedQueue,  ^{
        [self.stateStorage removeObjectForKey: operationID];
    });
}

-(id<UADSAbstractModuleOperationObject>)getOperationWithID: (NSString *)operationID {
    __block id<UADSAbstractModuleOperationObject> operation;
    dispatch_sync(self.synchronizedQueue,  ^{
        operation = self.stateStorage[operationID] ;
    });
    return operation;
}

-(_Nullable id)getDelegateForIDAndRemove: (NSString *)listenerID {
    __block id<UADSAbstractModuleOperationObject> state;
    dispatch_sync(self.synchronizedQueue,  ^{
        state = [self.stateStorage uads_removeObjectForKeyAndReturn: listenerID];
    });
    return state.delegate;
}


-(UADSInternalError *)expirationErrorOfOperation: (id<UADSAbstractModuleOperationObject>)operation {
    NSString *errorMessage = [NSString stringWithFormat: kUADSOperationExpirationMessage, operation.methodName, self.operationOperationTimeoutMs, operation.id];
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorAbstractModule
                                     andReason: kUADSInternalErrorAbstractModuleTimeout
                                    andMessage: errorMessage];
}

-(NSDictionary *)statesStorage {
    return _stateStorage;
}

+(void)setConfiguration:(USRVConfiguration *)config {
    configuration = config;
}

@end
