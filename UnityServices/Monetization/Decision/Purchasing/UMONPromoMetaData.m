#import "UMONPromoMetaData.h"

@interface UMONPromoMetaData ()
@property(nonatomic) NSTimeInterval offerDuration;
@property(strong) UPURProduct *premiumProduct;
@property(strong) NSArray<UMONItem *> *costs;
@property(strong) NSArray<UMONItem *> *payouts;
@property(strong) NSDictionary<NSString *, NSObject *> *userInfo;
@end

@implementation UMONPromoMetaData

-(instancetype)initWithBuilder:(UMONPromoMetaDataBuilder *)builder {
    if (self = [super init]) {
        self.impressionDate = builder.impressionDate;
        self.offerDuration = builder.offerDuration;
        self.premiumProduct = builder.premiumProduct;
        self.costs = builder.costs;
        self.payouts = builder.payouts;
        self.userInfo = builder.userInfo;
    }
    return self;
}

-(BOOL)isExpired {
    return self.timeRemaining <= 0;
}

-(BOOL)isPremium {
    return self.premiumProduct != nil;
}

-(NSTimeInterval)timeRemaining {
    if (self.impressionDate != nil) {
        return self.offerDuration - ([[NSDate date] timeIntervalSinceDate:self.impressionDate]);
    }
    return self.offerDuration;
}

-(UMONItem *)cost {
    return [self.costs firstObject];
}

-(UMONItem *)payout {
    return [self.payouts firstObject];
}

+(instancetype)build:(void (^)(UMONPromoMetaDataBuilder *))buildBlock {
    UMONPromoMetaDataBuilder *builder = [[UMONPromoMetaDataBuilder alloc] init];
    buildBlock(builder);
    return [[UMONPromoMetaData alloc] initWithBuilder:builder];
}
@end

@implementation UMONPromoMetaDataBuilder
@end
