#import "UMONCustomEvent.h"

@implementation UMONCustomEventBuilder
@end

@implementation UMONCustomEvent
-(instancetype)initWithBuilder:(UMONCustomEventBuilder *)builder {
    if (self = [super init]) {
        self.category = builder.category;
        self.type = builder.type;
        self.userInfo = builder.userInfo;
    }
    return self;
}
+(instancetype)build:(void (^)(UMONCustomEventBuilder *))buildBlock {
    UMONCustomEventBuilder* builder = [[UMONCustomEventBuilder alloc] init];
    buildBlock(builder);
    return [[UMONCustomEvent alloc] initWithBuilder:builder];
}

@end