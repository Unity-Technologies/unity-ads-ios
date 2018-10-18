#import "UMONPlacementContents.h"
#import "UMONNotAvailablePlacementContent.h"

@implementation UMONPlacementContents
static NSMutableDictionary<NSString *, UMONPlacementContent *> *placementContents;
static UMONPlacementContent* notAvailablePlacementContent;

+(void)initialize {
    placementContents = [[NSMutableDictionary alloc] init];
    notAvailablePlacementContent = [[UMONNotAvailablePlacementContent alloc] initWithPlacementId:@"" withParams:@{
        @"type": @"NOT_AVAILABLE"
    }];
}

+(nullable UMONPlacementContent *)getPlacementContent:(NSString *)placementId {
    return [placementContents valueForKey:placementId];
}

+(UMONPlacementContent *)putPlacementContent:(NSString *)placementId withPlacementContent:(UMONPlacementContent *)placementContent {
    UMONPlacementContent *previous = [self getPlacementContent:placementId];
    [placementContents setObject:placementContent forKey:placementId];
    return previous;
}

+(BOOL)isReady:(NSString *)placementId {
    UMONPlacementContent *placementContent = [self getPlacementContent:placementId];
    if (placementContent) {
        return placementContent.ready;
    }
    return false;
}

+(void)removePlacementContent:(NSString *)placementId {
    [placementContents removeObjectForKey:placementId];
}

+(void)setPlacementContentState:(NSString *)placementId withPlacementContentState:(UnityMonetizationPlacementContentState)state {
    UMONPlacementContent *placementContent = [self getPlacementContent:placementId];
    if (placementContent) {
        [placementContent setState:state];
    }
}
@end
