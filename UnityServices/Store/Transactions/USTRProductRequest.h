#import <StoreKit/StoreKit.h>

@interface USTRProductRequest : NSObject<SKProductsRequestDelegate>

@property (nonatomic, strong) NSArray<NSString*> *productIds;
@property (nonatomic, strong) SKProductsRequest *currentRequest;
@property (nonatomic, strong) NSNumber *requestId;

- (instancetype)initWithProductIds:(NSArray<NSString *>*)productIds requestId:(NSNumber*)requestId;
- (void)requestProducts;

@end
