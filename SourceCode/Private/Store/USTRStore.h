#import "USTRAppSheet.h"
#import "UADSTransactionObserver.h"
#import "UADSAppStoreReceiptReader.h"
#import "UADSSKProductReader.h"

typedef void (^USTRStoreProductsCompletion)(NSArray<NSDictionary *> *products);

@interface USTRStore : NSObject<UADSAppStoreReceiptReader>


+ (instancetype)newWithProductReader: (id<UADSSKProductReader>)productsReader
                    andReceiptReader: (id<UADSAppStoreReceiptReader>)receiptReader;
+ (instancetype)  sharedInstance;

- (void)startTransactionObserverWithCompletion: (UADSTransactionObserverCompletion)completion;
- (void)          stopTransactionObserver;
- (void)getProductsUsingIDs: (NSArray<NSString *> *)productIDs
                    success: (USTRStoreProductsCompletion)completion
                    onError: (UADSSKProductReaderErrorCompletion)onError;

+ (USTRAppSheet *)appSheet;


@end
