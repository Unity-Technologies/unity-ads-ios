#import <StoreKit/Storekit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSSKProductReaderCompletion)(NSArray<SKProduct *> *products);
typedef void (^UADSSKProductReaderErrorCompletion)(NSError *);

@protocol UADSSKProductReader <NSObject>

- (void)fetchProductsUsingIDS: (NSArray<NSString *> *)productIdentifiers
                   completion: (UADSSKProductReaderCompletion)completion
            onErrorCompletion: (UADSSKProductReaderErrorCompletion)onError;

@end

@interface UADSSKProductReaderImp : NSObject<UADSSKProductReader>
@end

NS_ASSUME_NONNULL_END
