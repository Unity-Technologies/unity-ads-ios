#import "UADSMediationMetaData.h"

@implementation UADSMediationMetaData

- (instancetype)init {
    self = [super initWithCategory:@"mediation"];
    return self;
}

- (void)setName:(NSString *)mediationNetworkName {
    [self set:@"name" value:mediationNetworkName];
}

- (void)setVersion:(NSString *)mediationSdkVersion {
    [self set:@"version" value:mediationSdkVersion];
}

- (void)setOrdinal:(int)mediationOrdinal {
    [self set:@"ordinal" value:[NSNumber numberWithInt:mediationOrdinal]];
}

- (void)setMissedImpressionOrdinal:(int)missedImpressionOrdinal {
    [self set:@"missedImpressionOrdinal" value:[NSNumber numberWithInt:missedImpressionOrdinal]];
}

@end
