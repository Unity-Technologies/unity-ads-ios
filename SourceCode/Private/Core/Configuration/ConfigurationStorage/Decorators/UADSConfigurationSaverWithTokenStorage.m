#import "UADSConfigurationSaverWithTokenStorage.h"
#import "UADSTokenStorage.h"

@interface UADSConfigurationSaverWithTokenStorage ()
@property (nonatomic, strong) id<UADSHeaderBiddingTokenCRUD>crud;
@property (nonatomic, strong) id<UADSConfigurationSaver>original;
@end

@implementation UADSConfigurationSaverWithTokenStorage

+ (instancetype)newWithTokenCRUD: (id<UADSHeaderBiddingTokenCRUD>)crud
                     andOriginal: (id<UADSConfigurationSaver>)original {
    UADSConfigurationSaverWithTokenStorage *base = [self new];

    base.crud = crud;
    base.original = original;
    return base;
}

- (void)saveConfiguration: (USRVConfiguration *)configuration {
    [self.original saveConfiguration: configuration];

    if (configuration.headerBiddingToken) {
        [self.hbTokenStorage setInitToken: configuration.headerBiddingToken];
    }
}

- (id<UADSHeaderBiddingTokenCRUD>)hbTokenStorage {
    return _crud;
}

@end
