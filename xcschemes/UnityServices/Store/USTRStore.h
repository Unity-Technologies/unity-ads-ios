#import "USTRAppSheet.h"

@interface USTRStore : NSObject

+ (void)startTransactionObserver;
+ (void)stopTransactionObserver;
+ (void)requestProductInfos:(NSArray<NSString *>*)productIds requestId:(NSNumber *)requestId;
+ (USTRAppSheet *)appSheet;
+ (NSData*)getReceipt;

@end
