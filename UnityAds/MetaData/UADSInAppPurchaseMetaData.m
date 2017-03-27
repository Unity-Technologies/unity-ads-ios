#import "UADSInAppPurchaseMetaData.h"
#import "UADSStorageManager.h"
#import "UADSStorage.h"

@implementation UADSInAppPurchaseMetaData

- (instancetype)init {
    self = [super initWithCategory:@"iap"];
    return self;
}

- (void)setProductId:(NSString *)productId {
    [self set:@"productId" value:productId];
}

- (void)setPrice:(NSNumber *)price {
    [self set:@"price" value:price];
}

- (void)setCurrency:(NSString *)currency {
    [self set:@"currency" value:currency];
}

- (void)setReceiptPurchaseData:(NSString *)receiptPurchaseData {
    [self set:@"receiptPurchaseData" value:receiptPurchaseData];
}

- (void)setSignature:(NSString *)signature {
    [self set:@"signature" value:signature];
}

- (void)commit {
    if ([UADSStorageManager init]) {
        UADSStorage *storage = [UADSStorageManager getStorage:kUnityAdsStorageTypePublic];

        if (self.entries && storage) {
            id purchaseObject = [storage getValueForKey:[NSString stringWithFormat:@"%@.purchases", self.category]];
            NSMutableArray *purchases = NULL;

            if (purchaseObject) {
                @try {
                    purchases = [NSMutableArray arrayWithArray:purchaseObject];
                }
                @catch (NSException *e) {
                    UADSLogError(@"Invalid object type for purchases");
                }
            }

            if (!purchases) {
                purchases = [[NSMutableArray alloc] init];
            }

            NSMutableDictionary *purchase = [[NSMutableDictionary alloc] init];

            @try {
                for (NSString *key in [self.entries allKeys]) {
                    [purchase setObject:[self.entries objectForKey:key] forKey:key];
                }

                NSNumber *ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
                [purchase setObject:ts forKey:@"ts"];
            }
            @catch (NSException *e) {
                UADSLogError(@"Error constructing purchase object");
                return;
            }

            [purchases addObject:purchase];
            [storage setValue:purchases forKey:[NSString stringWithFormat:@"%@.purchases", self.category]];
            [storage writeStorage];
            [storage sendEvent:@"SET" values:self.entries];
        }
        else {
            UADSLogError(@"Unity Ads could not commit metadata due to storage error or the data is null");
        }
    }
}

- (void)set:(NSString *)key value:(id)value {
    if (!self.entries) {
        self.entries = [[NSMutableDictionary alloc] init];
    }

    [self.entries setObject:value forKey:key];
}

@end
