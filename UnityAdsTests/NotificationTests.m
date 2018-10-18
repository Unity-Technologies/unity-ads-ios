#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface MockWebViewAppForViewNotificationTests : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *testReceiveNotificationException;
@property (nonatomic, strong) XCTestExpectation *testReceiveNotificationWithParameters;
@property (nonatomic, strong) XCTestExpectation *testReceiveTwoNotificationsException1;
@property (nonatomic, strong) XCTestExpectation *testReceiveTwoNotificationsException2;
@property (nonatomic, strong) NSDictionary *userInfo;

@end

@implementation MockWebViewAppForViewNotificationTests


- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... {
    if (eventId && [eventId isEqualToString:@"ACTION"] && category && [category isEqualToString:@"NOTIFICATION"] && [param1 isEqualToString:@"TestReceiveNotification"]) {
        [self.testReceiveNotificationException fulfill];
        
    }
    if (eventId && [eventId isEqualToString:@"ACTION"] && category && [category isEqualToString:@"NOTIFICATION"] && [param1 isEqualToString:@"TestTwoNotifications1"]) {
        [self.testReceiveTwoNotificationsException1 fulfill];
        
    }
    if (eventId && [eventId isEqualToString:@"ACTION"] && category && [category isEqualToString:@"NOTIFICATION"] && [param1 isEqualToString:@"TestTwoNotifications2"]) {
        [self.testReceiveTwoNotificationsException2 fulfill];
        
    }
    if (eventId && [eventId isEqualToString:@"ACTION"] && category && [category isEqualToString:@"NOTIFICATION"] && [param1 isEqualToString:@"TestReceiveNotificationWithParameters"]) {
        va_list args;
        va_start(args, param1);
        
        NSMutableArray *params = [[NSMutableArray alloc] init];
        
        __unsafe_unretained id arg = nil;
        
        if (param1) {
            [params addObject:param1];
            
            while ((arg = va_arg(args, id)) != nil) {
                [params addObject:arg];
            }
            
            va_end(args);
        }
        self.userInfo = params[1];
        [self.testReceiveNotificationWithParameters fulfill];
        
    }
    return true;
}

- (BOOL)invokeCallback:(USRVInvocation *)invocation {
    return true;
}
@end

@interface NotificationTests : XCTestCase

@end

@implementation NotificationTests

- (void)setUp {
    MockWebViewAppForViewNotificationTests *webApp = [[MockWebViewAppForViewNotificationTests alloc] init];
    [USRVWebViewApp setCurrentApp:webApp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testReceiveNotification {
    XCTestExpectation *expectation = [self expectationWithDescription:@"notificationException"];
    MockWebViewAppForViewNotificationTests *mockApp = (MockWebViewAppForViewNotificationTests *)[USRVWebViewApp getCurrentApp];
    [mockApp setTestReceiveNotificationException:expectation];
    
    [USRVNotificationObserver addObserver:@"TestReceiveNotification" userInfoKeys:nil targetObject:nil];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"TestReceiveNotification" object:nil];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
    
    [USRVNotificationObserver removeObserver:@"TestReceiveNotification" targetObject:nil];

}

- (void)testReceiveNotificationWithParameters {
    XCTestExpectation *expectation = [self expectationWithDescription:@"notificationException"];
    MockWebViewAppForViewNotificationTests *mockApp = (MockWebViewAppForViewNotificationTests *)[USRVWebViewApp getCurrentApp];
    [mockApp setTestReceiveNotificationWithParameters:expectation];

    NSDictionary *userInfo = @{@"cat" : @"Siamese", @"dog" : @"German Shepherd",};
    
    NSArray *keyArray = @[@"cat", @"dog", @"squirrel"];
    
    [USRVNotificationObserver addObserver:@"TestReceiveNotificationWithParameters" userInfoKeys:keyArray targetObject:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TestReceiveNotificationWithParameters" object:nil userInfo:userInfo];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertNotNil(mockApp.userInfo, "User info shouldn't be null");
    NSDictionary *dictionary = mockApp.userInfo;
    
    XCTAssertTrue([@"Siamese" isEqualToString:[dictionary valueForKey:@"cat"]], @"Value should be equal to Siamese");
    XCTAssertTrue([@"German Shepherd" isEqualToString:[dictionary valueForKey:@"dog"]], @"Value should be equal to German Shepherd");
    
    [USRVNotificationObserver removeObserver:@"TestReceiveNotificationWithParameters" targetObject:nil];
    
}

- (void)testReceiveTwoNotifications {
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"testReceiveTwoNotificationsException1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"testReceiveTwoNotificationsException2"];
    MockWebViewAppForViewNotificationTests *mockApp = (MockWebViewAppForViewNotificationTests *)[USRVWebViewApp getCurrentApp];
    [mockApp setTestReceiveTwoNotificationsException1:expectation1];
    [mockApp setTestReceiveTwoNotificationsException2:expectation2];
    
    NSArray *keyArray = @[@"cat", @"dog"];
    [USRVNotificationObserver addObserver:@"TestTwoNotifications1" userInfoKeys:nil targetObject:nil];
    [USRVNotificationObserver addObserver:@"TestTwoNotifications2" userInfoKeys:keyArray targetObject:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TestTwoNotifications1" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TestTwoNotifications2" object:nil];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
    }];
    
    [USRVNotificationObserver unregisterNotificationObserver];
    
}

@end
