#import "UMONPlacementContents.h"
#import "UnityMonetization.h"
#import "UMONClientProperties.h"

@implementation UnityMonetization
+(void)setDelegate:(id <UnityMonetizationDelegate>)delegate {
    [UMONClientProperties setDelegate:delegate];
}

+(id <UnityMonetizationDelegate>)getDelegate {
    return [UMONClientProperties getDelegate];
}

+(BOOL)isReady:(NSString *)placementId {
    return [UMONPlacementContents isReady:placementId];
}

+(UMONPlacementContent *)getPlacementContent:(NSString *)placementId {
    return [UMONPlacementContents getPlacementContent:placementId];
}
+(void)initialize:(NSString *)gameId delegate:(nullable id <UnityMonetizationDelegate>)delegate {
    [self initialize:gameId delegate:delegate testMode:false];
}
+(void)initialize:(NSString *)gameId delegate:(nullable id <UnityMonetizationDelegate>)delegate testMode:(BOOL)testMode {
    if (delegate != nil) {
        [self setDelegate:delegate];
    }
    [UMONClientProperties setMonetizationEnabled:YES];
    [UnityServices initialize:gameId delegate:delegate testMode:testMode];
}

@end
