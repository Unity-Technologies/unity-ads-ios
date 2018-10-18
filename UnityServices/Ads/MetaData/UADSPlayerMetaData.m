#import "UADSPlayerMetaData.h"

@implementation UADSPlayerMetaData

- (instancetype)init {
    self = [super initWithCategory:@"player"];
    return self;
}

- (void)setServerId:(NSString *)serverId {
    [self set:@"server_id" value:serverId];
}

@end