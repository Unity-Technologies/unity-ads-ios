#import "UADSHeaderBiddingTokenReaderSwiftBridge.h"

@implementation UADSHeaderBiddingTokenReaderSwiftBridge

- (void)getToken:(nonnull UADSHeaderBiddingTokenCompletion)completion {
    [[UADSServiceProviderContainer.sharedInstance.serviceProvider objBridge] getToken:^(NSDictionary * _Nonnull tokenDict) {
        completion([UADSHeaderBiddingToken newWithDictionary:tokenDict]);
    }];
}

@end


