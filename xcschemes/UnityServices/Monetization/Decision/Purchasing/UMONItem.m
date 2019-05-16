#import "UMONItem.h"

@interface UMONItem ()
@property(strong, nonatomic) NSString *itemId;
@property(nonatomic) double quantity;
@property(strong, nonatomic) NSString *type;
@end

@implementation UMONItem

-(instancetype)initWithBuilder:(UMONItemBuilder *)builder {
    if (self = [super init]) {
        self.itemId = builder.productId;
        self.quantity = builder.quantity;
        self.type = builder.type;
    }
    return self;
}
+(instancetype)build:(void (^)(UMONItemBuilder *))buildBlock {
    UMONItemBuilder *builder = [[UMONItemBuilder alloc] init];
    buildBlock(builder);
    return [[UMONItem alloc] initWithBuilder:builder];
}
@end

@implementation UMONItemBuilder
@end
