#import "UMONPromoMetaDataUtilities.h"

@implementation UMONPromoMetaDataUtilities
+(UMONPromoMetaData *)createPromoMetadataFromParamsMap:(NSDictionary *)params {
    UMONPromoMetaDataBuilder *builder = [[UMONPromoMetaDataBuilder alloc] init];
    builder.premiumProduct = [self productFromDictionary:params[@"product"]];
    builder.costs = [self getItemListFromList:params[@"costs"]];
    builder.payouts = [self getItemListFromList:params[@"payouts"]];
    builder.userInfo = params[@"userInfo"];
    builder.impressionDate = [self dateFromMillis:[params[@"impressionDate"] longValue]];
    builder.offerDuration = [self timeDurationFromMillis:[params[@"offerDuration"] longValue]];
    return [[UMONPromoMetaData alloc] initWithBuilder:builder];
}

+(NSArray<UMONItem *> *)getItemListFromList:(NSArray *)itemList {
    NSMutableArray<UMONItem *> *items = [[NSMutableArray alloc] init];
    for (NSDictionary *itemMap in itemList) {
        UMONItem *item = [self createItemFromMap:itemMap];
        [items addObject:item];
    }
    return [items copy];
}

+(UMONItem *)createItemFromMap:(NSDictionary *)itemMap {
    UMONItemBuilder *builder = [[UMONItemBuilder alloc] init];

    if (itemMap[@"productId"]) {
        builder.productId = itemMap[@"productId"];
    }

    if (itemMap[@"quantity"]) {
        builder.quantity = [itemMap[@"quantity"] doubleValue]; // TODO: Not sure if typecast or not
    }

    if (itemMap[@"type"]) {
        builder.type = itemMap[@"type"];
    }

    return [[UMONItem alloc] initWithBuilder:builder];
}

+(UPURProduct *)productFromDictionary:(NSDictionary *)params {
    return [UPURProduct build:^(UPURProductBuilder *builder) {
        builder.productId = params[@"productId"];
        builder.localizedPriceString = params[@"localizedPriceString"];
        builder.localizedTitle = params[@"localizedTitle"];
        builder.isoCurrencyCode = params[@"isoCurrencyCode"];
        builder.localizedPrice = [NSDecimalNumber decimalNumberWithDecimal:[params[@"localizedPrice"] decimalValue]];
        builder.localizedDescription = params[@"localizedDescription"];
        builder.productType = params[@"productType"];
    }];
}

+(NSTimeInterval)timeDurationFromMillis:(long)millis {
    return (millis / 1000.0f);
}

+(NSDate *)dateFromMillis:(long)millis {
    if (millis) {
        NSTimeInterval date = [self timeDurationFromMillis:millis];
        return [NSDate dateWithTimeIntervalSince1970:date];
    }
    return nil;
}

@end
