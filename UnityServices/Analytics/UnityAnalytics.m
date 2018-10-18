#import "UnityAnalytics.h"
#import "USRVWebViewApp.h"
#import "UANAWebViewEventCategory.h"
#import "UANAWebViewAnalyticsEvent.h"

@interface UnityAnalytics ()
@property(strong, nonatomic) NSMutableArray<NSDictionary *> *eventQueue;
@end

@implementation UnityAnalytics

+(instancetype)sharedInstance {
    static UnityAnalytics *unityAnalytics;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unityAnalytics = [[UnityAnalytics alloc] init];
    });
    return unityAnalytics;
}

+(void)onItemAcquired:(NSString *)transactionId itemId:(NSString *)itemId transactionContext:(NSString *)transactionContext level:(NSString *)level itemType:(NSString *)itemType amount:(float)amount balance:(float)balance acquisitionType:(UnityAnalyticsAcquisitionType)acquisitionType {
    NSDictionary *jsonObject = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000], // needs to be in milliseconds
                    @"name": @"item_acquired",
                    @"custom_params": @{
                            @"currency_type": NSStringFromUnityAnalyticsAcquisitionType(acquisitionType),
                            @"transaction_context": transactionContext ? transactionContext : [NSNull null],
                            @"amount": [NSNumber numberWithFloat:amount],
                            @"item_id": itemId ? itemId : [NSNull null],
                            @"balance": [NSNumber numberWithFloat:balance],
                            @"item_type": itemType ? itemType : [NSNull null],
                            @"level": level ? level : [NSNull null],
                            @"transaction_id": transactionId ? transactionId : [NSNull null]
                    }
            }
    };
    [[UnityAnalytics sharedInstance] postEvent:jsonObject];
}

+(void)onItemSpent:(NSString *)transactionId itemId:(NSString *)itemId transactionContext:(NSString *)transactionContext level:(NSString *)level itemType:(NSString *)itemType amount:(float)amount balance:(float)balance acquisitionType:(UnityAnalyticsAcquisitionType)acquisitionType {
    NSDictionary *jsonObject = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000], // needs to be in milliseconds
                    @"name": @"item_spent",
                    @"custom_params": @{
                            @"currency_type": NSStringFromUnityAnalyticsAcquisitionType(acquisitionType),
                            @"transaction_context": transactionContext ? transactionContext : [NSNull null],
                            @"amount": [NSNumber numberWithFloat:amount],
                            @"item_id": itemId ? itemId : [NSNull null],
                            @"balance": [NSNumber numberWithFloat:balance],
                            @"item_type": itemType ? itemType : [NSNull null],
                            @"level": level ? level : [NSNull null],
                            @"transaction_id": transactionId ? transactionId : [NSNull null]
                    }
            }
    };
    [[UnityAnalytics sharedInstance] postEvent:jsonObject];
}

+(void)onLevelFail:(int)levelIndex {
    NSDictionary *jsonObject = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000], // needs to be in milliseconds
                    @"name": @"level_fail",
                    @"custom_params": @{
                            @"level_index": [NSNumber numberWithInt:levelIndex]
                    }
            }
    };
    [[UnityAnalytics sharedInstance] postEvent:jsonObject];
}

+(void)onLevelUp:(int)theNewLevelIndex {
    NSDictionary *jsonObject = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000], // needs to be in milliseconds
                    @"name": @"level_up",
                    @"custom_params": @{
                            @"new_level_index": [NSNumber numberWithInt:theNewLevelIndex]
                    }
            }
    };
    [[UnityAnalytics sharedInstance] postEvent:jsonObject];
}

+(void)onAdComplete:(NSString *)placementId network:(NSString *)network rewarded:(BOOL)rewarded {
    NSDictionary *jsonObject = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000], // needs to be in milliseconds
                    @"name": @"ad_complete",
                    @"custom_params": @{
                            @"rewarded": [NSNumber numberWithBool:rewarded],
                            @"network": network ? network : [NSNull null],
                            @"placement_id": placementId ? placementId : [NSNull null]
                    }
            }
    };
    [[UnityAnalytics sharedInstance] postEvent:jsonObject];
}

+(void)onIapTransaction:(NSString *)productId amount:(float)amount currency:(NSString *)currency isPromo:(BOOL)isPromo receipt:(NSString *)receipt {
    NSDictionary *jsonObject = @{
            @"type": @"analytics.transaction.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000], // needs to be in milliseconds
                    @"productid": productId ? productId : [NSNull null],
                    @"amount": [NSNumber numberWithFloat:amount],
                    @"currency": currency ? currency : [NSNull null],
                    @"promo": [NSNumber numberWithBool:isPromo],
                    @"receipt": receipt ? receipt : [NSNull null]
            }
    };
    [[UnityAnalytics sharedInstance] postEvent:jsonObject];
}

+(void)onEvent:(NSDictionary<NSString *, NSObject *> *)jsonObject {
    [[UnityAnalytics sharedInstance] postEvent:jsonObject];
}

-(USRVWebViewApp *)getCurrentApp {
    return [USRVWebViewApp getCurrentApp];
}

-(void)postEvent:(NSDictionary *)eventData {
    if ([self.eventQueue count] < 200) {
        @try {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:&error];
            if (jsonData) {
                [self.eventQueue addObject:eventData];
            }
        } @catch (NSException *exception) {
            // Log exception
            USRVLogError(@"UnityAnalytics postEvent json conversion : %@", [exception reason]);
        }
    }
    USRVWebViewApp *currentApp = [self getCurrentApp];
    // only try to send eventQueue if there is something in it
    if (currentApp && [self.eventQueue count] > 0) {
        @try {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.eventQueue options:NSJSONWritingPrettyPrinted error:&error];
            if (!jsonData) {
                // log error
                if (error) {
                    USRVLogError(@"UnityAnalytics postEvent failed to convert queue for posting : %@", [error localizedDescription]);
                } else {
                    USRVLogError(@"UnityAnalytics postEvent failed to convert queue for posting");
                }
                self.eventQueue = [[NSMutableArray alloc] init]; // clear the queue so that new events can be sent
            } else {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                BOOL success = [currentApp sendEvent:NSStringFromUANAWebViewAnalyticsEvent(kWebViewAnalyticsEventPost) category:NSStringFromUANAWebViewEventCategory(kWebViewEventCategoryAnalytics) param1:jsonString, nil];
                if (success) {
                    // clear the cache
                    self.eventQueue = [[NSMutableArray alloc] init];
                }
            }
        }
        @catch (NSException *exception) {
            // log exception
            USRVLogError(@"UnityAnalytics postEvent : %@", [exception reason]);
            // clear the cache
            self.eventQueue = [[NSMutableArray alloc] init];
        }
    }

}

-(instancetype)init {
    if (self = [super init]) {
        self.eventQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
