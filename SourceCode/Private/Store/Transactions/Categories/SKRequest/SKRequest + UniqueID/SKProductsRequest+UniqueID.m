#import "SKProductsRequest+UniqueID.h"

@implementation SKProductsRequest (Category)

- (NSString *)uniqueID {
    return [NSString stringWithFormat: @"%lu", (unsigned long)self.hash];
}

@end
