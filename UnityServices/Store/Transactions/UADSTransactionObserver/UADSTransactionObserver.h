#import <StoreKit/StoreKit.h>
#import "UADSAppStoreReceiptReader.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^UADSTransactionObserverCompletion)(NSArray<NSDictionary*> *result);

@interface UADSTransactionObserver: NSObject<SKPaymentTransactionObserver>
+(instancetype)newWithReceiptReader: (id<UADSAppStoreReceiptReader>) reader
                      andCompletion: (UADSTransactionObserverCompletion) completion;
@end

NS_ASSUME_NONNULL_END
