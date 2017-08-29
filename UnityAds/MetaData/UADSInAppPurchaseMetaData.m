#import "UADSInAppPurchaseMetaData.h"
#import "UADSStorageManager.h"
#import "UADSStorage.h"

@implementation UADSInAppPurchaseMetaData

- (instancetype)init {
    self = [super init];
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

        if (self.storageContents && storage) {
            id purchaseObject = [storage getValueForKey:@"iap.purchases"];
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

            NSMutableDictionary *purchase = self.storageContents;

            @try {
                NSNumber *ts = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
                [purchase setObject:ts forKey:@"ts"];
            }
            @catch (NSException *e) {
                UADSLogError(@"Error constructing purchase object");
                return;
            }

            [purchases addObject:purchase];
            [storage set:@"iap.purchases" value:purchases];
            [storage writeStorage];
            [storage sendEvent:@"SET" values:[storage getValueForKey:@"iap.purchases"]];
        }
        else {
            UADSLogError(@"Unity Ads could not commit metadata due to storage error or the data is null");
        }
    }
}

- (BOOL)set:(NSString *)key value:(id)value {
    return [self setRaw:key value:value];
}

@end
