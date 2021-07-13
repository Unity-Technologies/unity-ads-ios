#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface MuteSwitchTestsWebApp : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) NSString *fulfillingEvent;
@end

@implementation MuteSwitchTestsWebApp
@synthesize expectation = _expectation;
@synthesize fulfillingEvent = _fulfillingEvent;

- (id)init {
    self = [super init];

    if (self) {
    }

    return self;
}

- (BOOL)invokeCallback: (USRVInvocation *)invocation {
    return true;
}

- (BOOL)sendEvent: (NSString *)eventId category: (NSString *)category params: (NSArray *)params {
    return true;
}

- (BOOL)sendEvent: (NSString *)eventId category: (NSString *)category param1: (id)param1, ... {
    NSLog(@"GOT_EVENT=%@", eventId);

    if (self.fulfillingEvent && [self.fulfillingEvent isEqualToString: eventId]) {
        NSLog(@"FULFILLING=%@", eventId);

        if (self.expectation) {
            [self.expectation fulfill];
        }
    }

    return true;
}

- (BOOL)invokeMethod: (NSString *)methodName className: (NSString *)className receiverClass: (NSString *)receiverClass callback: (NSString *)callback params: (NSArray *)params {
    return true;
}

@end

@interface MuteSwitchTests : XCTestCase
@end

@implementation MuteSwitchTests

- (void)setUp {
    [super setUp];

    MuteSwitchTestsWebApp *webviewApp = [[MuteSwitchTestsWebApp alloc] init];

    [USRVWebViewApp setCurrentApp: webviewApp];
    [webviewApp setWebAppLoaded: true];
    [webviewApp completeWebViewAppInitialization: true];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMuteSwitch {
    XCTestExpectation *muteSwitchExpectation = [self expectationWithDescription: @"expectation"];

    [(MuteSwitchTestsWebApp *)[USRVWebViewApp getCurrentApp] setExpectation: muteSwitchExpectation];
    [(MuteSwitchTestsWebApp *)[USRVWebViewApp getCurrentApp] setFulfillingEvent: @"MUTE_STATE_RECEIVED"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [USRVDevice checkIsMuted];
    });

    __block BOOL success = true;

    // Test waits up to 3 seconds, but immediately returns once fulfilled
    [self waitForExpectationsWithTimeout: 3
                                 handler: ^(NSError *_Nullable error) {
                                     if (error) {
                                         success = false;
                                     }
                                 }];

    XCTAssertTrue(success, @"Mute switch event not sent properly");
} /* testMuteSwitch */

@end
