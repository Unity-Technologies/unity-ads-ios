#import "UADSPurchasing.h"
#import "UADSApiPurchasing.h"
#import "UADSWebViewApp.h"

static NSString *unityAdsPurchasingVersionEvent = @"VERSION";
static NSString *unityAdsPurchasingProductCatalogEvent = @"CATALOG";
static NSString *unityAdsPurchasingCommandCallback = @"COMMAND";
static NSString *unityAdsPurchasingInitializationResult = @"INITIALIZATION";


NSString *NSStringFromPurchasingEvent(UnityAdsPurchasingEvent event) {
    switch (event) {
        case kUnityAdsPurchasingEventPurchasingVersion:
            return unityAdsPurchasingVersionEvent;
        case kUnityAdsPurchasingEventProductCatalog:
            return unityAdsPurchasingProductCatalogEvent;
        case kUnityAdsPurchasingEventPurchasingCommandCallback:
            return unityAdsPurchasingCommandCallback;
        case kUnityAdsPurchasingEventInitializationResult:
            return unityAdsPurchasingInitializationResult;
    }
}

static NSString *kUnityAdsPurchasingEventCategory = @"PURCHASING";

@implementation UADSPurchasing

#pragma mark Public Selectors

+ (void)initialize:(id<UADSPurchasingDelegate>)delegate {
    [UADSApiPurchasing setPurchasingDelegate:delegate];
}

+ (void)dispatchReturnEvent:(UnityAdsPurchasingEvent)event withPayload:(NSString *)payload {
    if ([UADSWebViewApp getCurrentApp] != nil) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromPurchasingEvent(event) category:kUnityAdsPurchasingEventCategory param1:payload, nil];
    }
    
}

@end
