#import "USTRApiSKAdNetwork.h"
#import "USRVWebViewCallback.h"
#import "SKAdNetworkFacade.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"

static NSString *const kUADSStoreKitWebAPISuccessEvent = @"SUCCESS";
static NSString *const kUADSStoreKitWebAPIFailedEvent = @"FAILED";
static NSString *const kUADSStoreKitWebAPIStartCategory = @"START_IMPRESSION";
static NSString *const kUADSStoreKitWebAPIEndCategory = @"END_IMPRESSION";

@implementation USTRApiSKAdNetwork

+ (SKAdNetworkFacade *)facade {
    return SKAdNetworkFacade.sharedInstance;
}

+ (USRVWebViewApp *)eventSender {
    return [USRVWebViewApp getCurrentApp];
}

+ (void)WebViewExposed_startImpression: (NSDictionary *)impressionJSON callback: (USRVWebViewCallback *)callback  {
    [self.facade startImpression: impressionJSON
               completionHandler : ^(NSError *_Nullable error) {
                   [self sendEventAsync: kUADSStoreKitWebAPIStartCategory
                               andError: error];
               }];
    [callback invoke: nil];
}

+ (void)WebViewExposed_endImpression: (NSDictionary *)impressionJSON
                            callback: (USRVWebViewCallback *)callback  {
    [self.facade endImpression: impressionJSON
             completionHandler: ^(NSError *_Nullable error) {
         [self sendEventAsync: kUADSStoreKitWebAPIEndCategory
                     andError: error];
     }];
    [callback invoke: nil];
}

+ (void)sendEvent: (NSString *)eventName andError: (NSError *_Nullable)error {
    NSString *suffix = error == nil ? kUADSStoreKitWebAPISuccessEvent : kUADSStoreKitWebAPIFailedEvent;
    NSString *finalEvent = [NSString stringWithFormat: @"%@_%@", eventName, suffix];
    NSString *category = USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategorySKAdNetwork);

    if (error) {
        NSString *errorMessage = error.userInfo[NSDebugDescriptionErrorKey] ? : error.localizedDescription;
        [self.eventSender sendEvent: finalEvent
                           category: category
                             param1: errorMessage, nil];
    } else {
        [self.eventSender sendEvent: finalEvent
                           category: category
                             param1: nil];
    }
}

+ (void)sendEventAsync: (NSString *)eventName andError: (NSError *_Nullable)error {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self sendEvent: eventName
               andError: error];
    });
}

@end
