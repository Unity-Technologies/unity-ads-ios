#import <XCTest/XCTest.h>
#import "USRVWebViewApp.h"
#import "UnityAnalytics.h"

@interface NSDate (Mock)
+(instancetype)date;
@end

@implementation NSDate (Mock)
+(instancetype)date {
    return [NSDate dateWithTimeIntervalSince1970:12345];
}
@end

@interface UnityAnalytics (Mock)
@property(strong, nonatomic) NSMutableArray<NSDictionary *> *eventQueue;

+(instancetype)sharedInstance;

+(NSMutableArray<NSDictionary *> *)getEventQueue;
@end

@implementation UnityAnalytics (Mock)
+(NSMutableArray<NSDictionary *> *)getEventQueue {
    return [UnityAnalytics sharedInstance].eventQueue;
}

-(USRVWebViewApp *)getCurrentApp {
    return nil;
}
@end

@interface UnityAnalyticsTests : XCTestCase
@end

@implementation UnityAnalyticsTests

-(void)setUp {
    [super setUp];
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    [eventQueue removeAllObjects];
}

-(void)tearDown {
    [super setUp];
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    [eventQueue removeAllObjects];
}

-(void)testOnItemAcquired {
    [UnityAnalytics onItemAcquired:@"transactionId" itemId:@"productId" transactionContext:@"transactionContext" level:@"level" itemType:@"itemType" amount:49.5F balance:2782787.87237F acquisitionType:kUnityAnalyticsAcquisitionTypeSoft];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"item_acquired",
                    @"custom_params": @{
                            @"currency_type": NSStringFromUnityAnalyticsAcquisitionType(kUnityAnalyticsAcquisitionTypeSoft),
                            @"transaction_context": @"transactionContext",
                            @"amount": [NSNumber numberWithFloat:49.5],
                            @"item_id": @"productId",
                            @"balance": [NSNumber numberWithFloat:2782787.87237],
                            @"item_type": @"itemType",
                            @"level": @"level",
                            @"transaction_id": @"transactionId"
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnItemAcquiredNull {
    [UnityAnalytics onItemAcquired:nil itemId:nil transactionContext:nil level:nil itemType:nil amount:49.5F balance:2782787.87237F acquisitionType:kUnityAnalyticsAcquisitionTypeSoft];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"item_acquired",
                    @"custom_params": @{
                            @"currency_type": NSStringFromUnityAnalyticsAcquisitionType(kUnityAnalyticsAcquisitionTypeSoft),
                            @"transaction_context": [NSNull null],
                            @"amount": [NSNumber numberWithFloat:49.5],
                            @"item_id": [NSNull null],
                            @"balance": [NSNumber numberWithFloat:2782787.87237],
                            @"item_type": [NSNull null],
                            @"level": [NSNull null],
                            @"transaction_id": [NSNull null]
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnItemSpent {
    [UnityAnalytics onItemSpent:@"transactionId" itemId:@"productId" transactionContext:@"transactionContext" level:@"level" itemType:@"itemType" amount:49.5F balance:2782787.87237F acquisitionType:kUnityAnalyticsAcquisitionTypePremium];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"item_spent",
                    @"custom_params": @{
                            @"currency_type": NSStringFromUnityAnalyticsAcquisitionType(kUnityAnalyticsAcquisitionTypePremium),
                            @"transaction_context": @"transactionContext",
                            @"amount": [NSNumber numberWithFloat:49.5],
                            @"item_id": @"productId",
                            @"balance": [NSNumber numberWithFloat:2782787.87237],
                            @"item_type": @"itemType",
                            @"level": @"level",
                            @"transaction_id": @"transactionId"
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}


-(void)testOnItemSpentNull {
    [UnityAnalytics onItemSpent:nil itemId:nil transactionContext:nil level:nil itemType:nil amount:49.5F balance:2782787.87237F acquisitionType:kUnityAnalyticsAcquisitionTypePremium];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"item_spent",
                    @"custom_params": @{
                            @"currency_type": NSStringFromUnityAnalyticsAcquisitionType(kUnityAnalyticsAcquisitionTypePremium),
                            @"transaction_context": [NSNull null],
                            @"amount": [NSNumber numberWithFloat:49.5],
                            @"item_id": [NSNull null],
                            @"balance": [NSNumber numberWithFloat:2782787.87237],
                            @"item_type": [NSNull null],
                            @"level": [NSNull null],
                            @"transaction_id": [NSNull null]
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnLevelFail {
    [UnityAnalytics onLevelFail:8789];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"level_fail",
                    @"custom_params": @{
                            @"level_index": [NSNumber numberWithInt:8789]
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnLevelUp {
    [UnityAnalytics onLevelUp:334];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"level_up",
                    @"custom_params": @{
                            @"new_level_index": [NSNumber numberWithInt:334]
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnAdComplete {
    [UnityAnalytics onAdComplete:@"myCoolPlacement" network:@"admob" rewarded:YES];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"ad_complete",
                    @"custom_params": @{
                            @"rewarded": [NSNumber numberWithBool:YES],
                            @"network": @"admob",
                            @"placement_id": @"myCoolPlacement"
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnAdCompleteNull {
    [UnityAnalytics onAdComplete:nil network:nil rewarded:YES];
    NSDictionary *expected = @{
            @"type": @"analytics.custom.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"name": @"ad_complete",
                    @"custom_params": @{
                            @"rewarded": [NSNumber numberWithBool:YES],
                            @"network": [NSNull null],
                            @"placement_id": [NSNull null]
                    }
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnIapTransaction {
    [UnityAnalytics onIapTransaction:@"productId" amount:45.78F currency:@"USD" isPromo:YES receipt:@"{\"data\": \"{\"Store\":\"fake\",\"TransactionID\":\"ce7bb1ca-bd34-4ffb-bdee-83d2784336d8\",\"Payload\":\"{ \\\"this\\\" : \\\"is a fake receipt\\\" }\"}\"}"];
    NSDictionary *expected = @{
            @"type": @"analytics.transaction.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"productid": @"productId",
                    @"amount": [NSNumber numberWithFloat:45.78F],
                    @"currency": @"USD",
                    @"promo": [NSNumber numberWithBool:YES],
                    @"receipt": @"{\"data\": \"{\"Store\":\"fake\",\"TransactionID\":\"ce7bb1ca-bd34-4ffb-bdee-83d2784336d8\",\"Payload\":\"{ \\\"this\\\" : \\\"is a fake receipt\\\" }\"}\"}"
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnIapTransactionNull {
    [UnityAnalytics onIapTransaction:nil amount:45.78F currency:nil isPromo:YES receipt:nil];
    NSDictionary *expected = @{
            @"type": @"analytics.transaction.v1",
            @"msg": @{
                    @"ts": [NSNumber numberWithLong:((long) [[NSDate date] timeIntervalSince1970]) * 1000],
                    @"productid": [NSNull null],
                    @"amount": [NSNumber numberWithFloat:45.78F],
                    @"currency": [NSNull null],
                    @"promo": [NSNumber numberWithBool:YES],
                    @"receipt": [NSNull null]
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testOnEvent {
    [UnityAnalytics onEvent:@{
            @"testString": @"testValue",
            @"testNumber": [NSNumber numberWithInt:5],
            @"testBool": [NSNumber numberWithBool:YES],
            @"testArray": @[@"first", @"second"],
            @"testObject": @{
                    @"one": @"oneValue",
                    @"two": @{}
            }
    }];
    NSDictionary *expected = @{
            @"testString": @"testValue",
            @"testNumber": [NSNumber numberWithInt:5],
            @"testBool": [NSNumber numberWithBool:YES],
            @"testArray": @[@"first", @"second"],
            @"testObject": @{
                    @"one": @"oneValue",
                    @"two": @{}
            }
    };
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    NSDictionary *event = [eventQueue objectAtIndex:0];
    XCTAssertEqualObjects(expected, event);
}

-(void)testMultipleEvents {
    [UnityAnalytics onAdComplete:@"myCoolPlacement" network:@"admob" rewarded:YES];
    [UnityAnalytics onAdComplete:@"myCoolPlacement" network:@"admob" rewarded:YES];
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    XCTAssertEqual(2, [eventQueue count]);
}

-(void)testMaximumQueuedEvents {
    for (int i = 0; i < 200; i++) {
        [UnityAnalytics onAdComplete:@"myCoolPlacement" network:@"admob" rewarded:YES];
    }
    [UnityAnalytics onAdComplete:@"myCoolPlacement" network:@"admob" rewarded:YES];
    NSMutableArray <NSDictionary *> *eventQueue = [UnityAnalytics getEventQueue];
    XCTAssertEqual(200, [eventQueue count]);
}

@end