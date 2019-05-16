#import "UPURTransactionDetails+JsonAdditions.h"

@implementation UPURTransactionDetails (JsonAdditions)
-(NSDictionary *)getJSONDictionary {
    return @{
        @"productId": self.productId ? self.productId : [NSNull null],
        @"transactionId": self.transactionId ? self.transactionId : [NSNull null],
        @"receipt": self.receipt ? self.receipt : [NSNull null],
        @"price": self.price ? self.price : [NSNull null],
        @"currency": self.currency ? self.currency : [NSNull null],
        @"extras": self.extras ? self.extras : [NSNull null]
    };
}
@end
