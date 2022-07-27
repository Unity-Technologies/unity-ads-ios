#import "SKProductsRequest+UniqueID.h"

@implementation SKProductsRequest (Category)

- (NSString *)uads_uniqueID {
    return [NSString stringWithFormat: @"%lu", (unsigned long)self.hash];
}

@end
