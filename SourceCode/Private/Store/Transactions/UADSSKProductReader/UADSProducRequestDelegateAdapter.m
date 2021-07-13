#import "UADSProducRequestDelegateAdapter.h"

@interface UADSProducRequestDelegateAdapter ()
@property (nonatomic, strong) UADSSKProductReaderCompletion completion;
@property (nonatomic, strong) UADSSKProductReaderErrorCompletion onError;
@end

@implementation UADSProducRequestDelegateAdapter

+ (instancetype)newWithCompletion: (nonnull UADSSKProductReaderCompletion)completion
                onErrorCompletion: (nonnull UADSSKProductReaderErrorCompletion)onError {
    UADSProducRequestDelegateAdapter *obj = [[self alloc] init];

    obj.completion = completion;
    obj.onError = onError;
    return obj;
}

- (void)productsRequest: (SKProductsRequest *)request
     didReceiveResponse: (SKProductsResponse *)response {
    NSArray<SKProduct *> *array = response.products ? : [[NSArray alloc] init];

    self.completion(array);
}

@end
