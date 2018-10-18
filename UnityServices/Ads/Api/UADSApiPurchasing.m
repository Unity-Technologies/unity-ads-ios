#import "UADSApiPurchasing.h"
#import "USRVWebViewCallback.h"

static NSString *unityAdsPurchasingErrorNullInterface = @"PURCHASE_INTERFACE_NULL";

typedef NS_ENUM(NSInteger, UnityAdsPurchasingError) {
    kUnityAdsPurchasingErrorNullInterface
};

NSString *NSStringFromPurchasingError(UnityAdsPurchasingError error) {
    switch (error) {
        case kUnityAdsPurchasingErrorNullInterface:
            return unityAdsPurchasingErrorNullInterface;
    }
}

@implementation UADSApiPurchasing

static id<UADSPurchasingDelegate> internalPurchasingDelegate = nil;

+ (id<UADSPurchasingDelegate>)getPurchasingDelegate {
    return internalPurchasingDelegate;
}

+ (void)setPurchasingDelegate:(id<UADSPurchasingDelegate>)purchasingDelegate {
    internalPurchasingDelegate = purchasingDelegate;
}

+ (void)WebViewExposed_getPromoVersion:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSApiPurchasing getPurchasingDelegate] && [[UADSApiPurchasing getPurchasingDelegate] conformsToProtocol:@protocol(UADSPurchasingDelegate)]) {
            if ([(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] respondsToSelector:@selector(unityAdsPurchasingGetPurchasingVersion)]) {
                [(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] unityAdsPurchasingGetPurchasingVersion];
            }
        }
    });
    if ([UADSApiPurchasing getPurchasingDelegate]) {
        [callback invoke:nil];
    } else {
        [callback error:NSStringFromPurchasingError(kUnityAdsPurchasingErrorNullInterface) arg1:nil];
    }
}

+ (void)WebViewExposed_getPromoCatalog:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSApiPurchasing getPurchasingDelegate] && [[UADSApiPurchasing getPurchasingDelegate] conformsToProtocol:@protocol(UADSPurchasingDelegate)]) {
            if ([(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] respondsToSelector:@selector(unityAdsPurchasingGetProductCatalog)]) {
                [(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] unityAdsPurchasingGetProductCatalog];
            }
        }
    });
    if ([UADSApiPurchasing getPurchasingDelegate]) {
        [callback invoke:nil];
    } else {
        [callback error:NSStringFromPurchasingError(kUnityAdsPurchasingErrorNullInterface) arg1:nil];
    }
}

+ (void)WebViewExposed_initiatePurchasingCommand:(NSString *)eventString callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSApiPurchasing getPurchasingDelegate] && [[UADSApiPurchasing getPurchasingDelegate] conformsToProtocol:@protocol(UADSPurchasingDelegate)]) {
            if ([(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] respondsToSelector:@selector(unityAdsPurchasingDidInitiatePurchasingCommand:)]) {
                [(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] unityAdsPurchasingDidInitiatePurchasingCommand:eventString];
            }
        }
    });
    if ([UADSApiPurchasing getPurchasingDelegate]) {
        [callback invoke:nil];
    } else {
        [callback error:NSStringFromPurchasingError(kUnityAdsPurchasingErrorNullInterface) arg1:nil];
    }
}

+ (void)WebViewExposed_initializePurchasing:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSApiPurchasing getPurchasingDelegate] && [[UADSApiPurchasing getPurchasingDelegate] conformsToProtocol:@protocol(UADSPurchasingDelegate)]) {
            if ([(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] respondsToSelector:@selector(unityAdsPurchasingInitialize)]) {
                [(id<UADSPurchasingDelegate>)[UADSApiPurchasing getPurchasingDelegate] unityAdsPurchasingInitialize];
            }
        }
    });
    if ([UADSApiPurchasing getPurchasingDelegate]) {
        [callback invoke:nil];
    } else {
        [callback error:NSStringFromPurchasingError(kUnityAdsPurchasingErrorNullInterface) arg1:nil];
    }
}
@end
