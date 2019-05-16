typedef NS_ENUM(NSInteger, UPURPurchasingEvent) {
    kUPURPurchasingEventProductsRetrieved,
    kUPURPurchasingEventTransactionComplete,
    kUPURPurchasingEventTransactionError
};
NSString *NSStringFromUPURPurchasingEvent(UPURPurchasingEvent);
