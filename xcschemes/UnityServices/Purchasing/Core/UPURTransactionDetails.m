#import "UPURTransactionDetails.h"


@interface UPURTransactionDetails ()
@property(strong, nonatomic) NSString *productId;
@property(strong, nonatomic) NSString *transactionId;
@property(strong, nonatomic) NSString *receipt;
@property(strong, nonatomic) NSDecimalNumber *price;
@property(strong, nonatomic) NSString *currency;
@property(strong, nonatomic) NSDictionary *extras;
@end

@implementation UPURTransactionDetails

-(instancetype)initWithBuilder:(UPURTransactionDetailsBuilder *)builder {
    if (self = [super init]) {
        self.productId = builder.productId;
        self.transactionId = builder.transactionId;
        self.receipt = builder.receipt;
        self.price = builder.price;
        self.currency = builder.currency;
        self.extras = [builder.extras mutableCopy];
    }
    return self;
}

+(instancetype)build:(void (^)(UPURTransactionDetailsBuilder *))buildBlock {
    UPURTransactionDetailsBuilder *builder = [[UPURTransactionDetailsBuilder alloc] init];
    buildBlock(builder);
    return [[UPURTransactionDetails alloc] initWithBuilder:builder];
}
@end

@implementation UPURTransactionDetailsBuilder
-(instancetype)init {
    if (self = [super init]) {
        self.extras = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(UPURTransactionDetailsBuilder *)putExtra:(NSString *)key value:(NSObject *)value {
    if (self) {
        [self.extras setObject:value forKey:key];
    }
    return self;
}
@end

