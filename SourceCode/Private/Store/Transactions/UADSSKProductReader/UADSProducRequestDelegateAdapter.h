#import <StoreKit/Storekit.h>
#import "UADSSKProductReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSProducRequestDelegateAdapter : NSObject<SKProductsRequestDelegate>
+ (instancetype)newWithCompletion: (UADSSKProductReaderCompletion)completion
                onErrorCompletion: (UADSSKProductReaderErrorCompletion)onError;
@end

NS_ASSUME_NONNULL_END
