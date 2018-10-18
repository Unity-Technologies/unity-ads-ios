
#import "UPURTransactionErrorDetails+JsonAdditions.h"

@implementation UPURTransactionErrorDetails (JsonAdditions)
-(NSDictionary *)getJSONDictionary {
    return @{
            @"transactionError": NSStringFromUPURTransactionError(self.transactionError),
            @"exceptionMessage": self.exceptionMessage ? self.exceptionMessage : [NSNull null],
            @"store": NSStringFromUPURAppStore(self.store),
            @"storeSpecificErrorCode": self.storeSpecificErrorCode ? self.storeSpecificErrorCode : [NSNull null],
            @"extras": self.extras ? self.extras : [NSNull null]
    };
}
@end
