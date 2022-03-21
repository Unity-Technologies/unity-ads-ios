#import "UADSConfigurationPersistence.h"
#import "UADSTokenStorage.h"

@interface UADSConfigurationPersistence ()
@property (nonatomic, strong) id<UADSHeaderBiddingTokenCRUD>crud;
@end

@implementation UADSConfigurationPersistence

+ (instancetype)newWithTokenCRUD: (id<UADSHeaderBiddingTokenCRUD>)crud {
    UADSConfigurationPersistence *base = [self new];

    base.crud = crud;
    return base;
}

- (void)saveConfiguration: (USRVConfiguration *)configuration {
    [configuration saveToDisk];

    if (configuration.headerBiddingToken) {
        [self.tokenReader setInitToken: configuration.headerBiddingToken];
    }
}

- (id<UADSHeaderBiddingTokenCRUD>)tokenReader {
    return _crud;
}

@end
