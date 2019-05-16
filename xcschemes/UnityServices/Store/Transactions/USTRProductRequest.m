#import "USTRProductRequest.h"
#import "USRVWebViewApp.h"

@implementation USTRProductRequest

static NSMutableArray<USTRProductRequest*> *requests;

- (instancetype)initWithProductIds:(NSArray<NSString*>*)productIds requestId:(NSNumber*)requestId {
    self = [super init];
    
    if (self) {
        [self setProductIds:productIds];
        [self setRequestId:requestId];
        if (!requests) {
            requests = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (void)requestProducts {
    NSSet *productIdentifiers = [NSSet setWithArray:self.productIds];
    [self setCurrentRequest:[[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers]];
    [[self currentRequest] setDelegate:self];
    [self addToActiveRequests];
    [[self currentRequest] start];
}

- (void)addToActiveRequests {
    @synchronized (requests) {
        [requests addObject:self];
    }
}

- (void)removeFromActiveRequests {
    @synchronized (requests) {
        [requests removeObject:self];
    }
}

- (void)sendProducts:(NSArray<SKProduct*>*)products invalidProducts:(NSArray<NSString*>*)invalidProducts {
    if (products) {
        int productCount = (int)products.count;
        if (invalidProducts) {
            productCount += invalidProducts.count;
        }

        if (productCount < 1) {
            [[USRVWebViewApp getCurrentApp] sendEvent:@"PRODUCT_REQUEST_ERROR_NO_PRODUCTS" category:@"STORE" param1:self.requestId, nil];
            return;
        }

        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        for (SKProduct *product in products) {
            if (product) {
                NSMutableDictionary *productDict = [[NSMutableDictionary alloc] init];

                if (product.downloadable) {
                    [productDict setObject:[NSNumber numberWithBool:product.downloadable] forKey:@"downloadable"];
                }
                if (product.localizedTitle) {
                    [productDict setObject:product.localizedTitle forKey:@"localizedTitle"];
                }
                if (product.localizedDescription) {
                    [productDict setObject:product.localizedDescription forKey:@"localizedDescription"];
                }
                if (product.price) {
                    [productDict setObject:product.price forKey:@"price"];
                }

                NSMutableDictionary *priceLocaleDict = [[NSMutableDictionary alloc] init];

                if (product.priceLocale && [product.priceLocale valueForKey:@"countryCode"]) {
                    [priceLocaleDict setObject:[product.priceLocale valueForKey:@"countryCode"] forKey:@"countryCode"];
                }
                if (product.priceLocale && [product.priceLocale valueForKey:@"currencyCode"]) {
                    [priceLocaleDict setObject:[product.priceLocale valueForKey:@"currencyCode"] forKey:@"currencyCode"];
                }
                if (product.priceLocale && [product.priceLocale valueForKey:@"currencySymbol"]) {
                    [priceLocaleDict setObject:[product.priceLocale valueForKey:@"currencySymbol"] forKey:@"currencySymbol"];
                }

                if (priceLocaleDict) {
                    [productDict setObject:priceLocaleDict forKey:@"priceLocale"];
                }

                if ([product valueForKey:@"subscriptionPeriod"]) {
                    id subscriptionPeriod = [product valueForKey:@"subscriptionPeriod"];
                    NSUInteger numOfUnits = (NSUInteger)[subscriptionPeriod valueForKey:@"numberOfUnits"];
                    BOOL isSubscription = (subscriptionPeriod != nil) && (numOfUnits > 0);

                    if (isSubscription) {
                        NSMutableDictionary *subDictionary = [[NSMutableDictionary alloc] init];
                        [subDictionary setObject:[NSNumber numberWithUnsignedInteger:numOfUnits] forKey:@"numberOfUnits"];

                        if ([subscriptionPeriod valueForKey:@"unit"]) {
                            NSNumber *periodUnit = [NSNumber numberWithUnsignedInteger:(NSUInteger)[subscriptionPeriod valueForKey:@"unit"]];
                            [subDictionary setObject:periodUnit forKey:@"periodUnit"];
                        }

                        id introductoryPrice = [product valueForKey:@"introductoryPrice"];
                        if (introductoryPrice) {
                            if ([introductoryPrice valueForKey:@"price"]) {
                                [subDictionary setObject:[introductoryPrice valueForKey:@"price"] forKey:@"introductoryPrice"];
                            }

                            if ([introductoryPrice valueForKey:@"subscriptionPeriod"]) {
                                id introductorySubscriptionPeriod = [introductoryPrice valueForKey:@"subscriptionPeriod"];
                                if (introductorySubscriptionPeriod) {
                                    if ([introductorySubscriptionPeriod valueForKey:@"unit"]) {
                                        [subDictionary setObject:[introductorySubscriptionPeriod valueForKey:@"unit"] forKey:@"introductorySubPeriodUnit"];
                                    }
                                    if ([introductorySubscriptionPeriod valueForKey:@"numberOfUnits"]) {
                                        [subDictionary setObject:[introductorySubscriptionPeriod valueForKey:@"numberOfUnits"] forKey:@"introductorySubPeriodNumOfUnits"];
                                    }
                                }
                            }
                        }

                        [productDict setObject:subDictionary forKey:@"subscription"];
                    }
                }

                [dictionary setObject:productDict forKey:product.productIdentifier];
            }
        }

        [[USRVWebViewApp getCurrentApp] sendEvent:@"PRODUCT_REQUEST_COMPLETE" category:@"STORE" param1:self.requestId, dictionary, nil];
    }
    else {
        [[USRVWebViewApp getCurrentApp] sendEvent:@"PRODUCT_REQUEST_ERROR_NO_PRODUCTS" category:@"STORE" param1:self.requestId, nil];
    }
}

/* DELEGATE */

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    NSArray *invalidProductIdentifiers = response.invalidProductIdentifiers;
   
    [self sendProducts:products invalidProducts:invalidProductIdentifiers];
}

- (void)requestDidFinish:(SKRequest *)request {
    [self removeFromActiveRequests];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [[USRVWebViewApp getCurrentApp] sendEvent:@"PRODUCT_REQUEST_FAILED" category:@"STORE" param1:self.requestId, [error description], nil];

    [self removeFromActiveRequests];
}

@end
