#import "UPURProduct.h"

@interface UPURProduct ()
@property(strong, nonatomic) NSString *productId;
@property(strong, nonatomic) NSString *localizedPriceString;
@property(strong, nonatomic) NSString *localizedTitle;
@property(strong, nonatomic) NSString *isoCurrencyCode;
@property(strong, nonatomic) NSDecimalNumber *localizedPrice;
@property(strong, nonatomic) NSString *localizedDescription;
@property(strong, nonatomic) NSString *productType;
@end

@implementation UPURProduct

+(instancetype)build:(void (^)(UPURProductBuilder *))buildBlock {
    UPURProductBuilder *builder = [[UPURProductBuilder alloc] init];
    buildBlock(builder);
    return [[UPURProduct alloc] initWithBuilder:builder];
}
-(instancetype)initWithBuilder:(UPURProductBuilder *)builder {
    if (self = [super init]) {
        self.productId = builder.productId;
        self.localizedPriceString = builder.localizedPriceString;
        self.localizedTitle = builder.localizedTitle;
        self.isoCurrencyCode = builder.isoCurrencyCode;
        self.localizedPrice = builder.localizedPrice;
        self.localizedDescription = builder.localizedDescription;
        self.productType = builder.productType;
    }
    return self;
}

@end

@implementation UPURProductBuilder
@end

