#import "UADSPurchasing.h"
#import "UADSApiPurchasing.h"
#import "USRVWebViewApp.h"

static NSString *unityAdsPurchasingVersionEvent = @"VERSION";
static NSString *unityAdsPurchasingProductCatalogEvent = @"CATALOG";
static NSString *unityAdsPurchasingCommandCallback = @"COMMAND";
static NSString *unityAdsPurchasingInitializationResult = @"INITIALIZATION";
static NSString *unityAdsPurchasingEvent = @"EVENT";

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
        case kUnityAdsPurchasingEventPurchasingEvent:
            return unityAdsPurchasingEvent;
    }
}

static NSString *kUnityAdsPurchasingEventCategory = @"PURCHASING";

@implementation UADSPurchasing

#pragma mark Public Selectors

+ (void)initialize:(id<UADSPurchasingDelegate>)delegate {
    [UADSApiPurchasing setPurchasingDelegate:delegate];
}

+ (void)dispatchReturnEvent:(UnityAdsPurchasingEvent)event withPayload:(NSString *)payload {
    if ([USRVWebViewApp getCurrentApp] != nil) {
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromPurchasingEvent(event) category:kUnityAdsPurchasingEventCategory param1:payload, nil];
    }
    
}

@end
