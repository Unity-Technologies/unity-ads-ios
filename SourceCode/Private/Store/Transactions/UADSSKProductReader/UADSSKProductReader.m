#import "UADSSKProductReader.h"
#import "UADSProducRequestDelegateAdapter.h"
#import "SKProductsRequest+UniqueID.h"

@interface UADSSKProductReaderImp ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, SKProductsRequest *> *storage;
@property (nonatomic) dispatch_queue_t synchronizeQueue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UADSProducRequestDelegateAdapter *> *delegateStorage;
@end

@implementation UADSSKProductReaderImp

- (instancetype)init {
    self = [super init];

    if (self) {
        self.storage = [[NSMutableDictionary alloc] init];
        self.delegateStorage = [[NSMutableDictionary alloc] init];
        self.synchronizeQueue = dispatch_queue_create("UADSSKProductReader Queue", DISPATCH_QUEUE_SERIAL);
    }

    return self;
}

- (void)fetchProductsUsingIDS: (NSArray<NSString *> *)productIdentifiers
                   completion: (UADSSKProductReaderCompletion)completion
            onErrorCompletion: (nonnull UADSSKProductReaderErrorCompletion)onError {
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers: [NSSet setWithArray: productIdentifiers]];

    __weak UADSSKProductReaderImp *weakSelf = self;
    UADSProducRequestDelegateAdapter *delegate = [UADSProducRequestDelegateAdapter newWithCompletion: ^(NSArray<SKProduct *> *_Nonnull products) {
        [weakSelf removeRequest: productsRequest];
        completion(products);
    }
                                                                                   onErrorCompletion: ^(NSError *_Nonnull error) {
                                                                                       [weakSelf removeRequest: productsRequest];
                                                                                       onError(error);
                                                                                   }];

    [self storeRequest: productsRequest
           andDelegate: delegate];

    productsRequest.delegate = delegate;

    [productsRequest start];
} /* fetchProductsUsingIDS */

- (void)storeRequest: (SKProductsRequest *)request
         andDelegate: (UADSProducRequestDelegateAdapter *)delegate {
    dispatch_sync(_synchronizeQueue, ^{
        self.storage[request.uniqueID] = request;
        self.delegateStorage[request.uniqueID] = delegate;
    });
}

- (void)removeRequest: (SKProductsRequest *)request {
    dispatch_sync(_synchronizeQueue, ^{
        [self.storage removeObjectForKey: request.uniqueID];
        [self.delegateStorage removeObjectForKey: request.uniqueID];
    });
}

@end
