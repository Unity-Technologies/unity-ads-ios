#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "UADSApiWebPlayer.h"

@interface WebPlayerTestsWebApp : USRVWebViewApp
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) NSString *fulfillingEvent;
@property (nonatomic, strong) NSString *collectEvents;
@property (nonatomic, strong) NSMutableArray *collectedEvents;
@end

@implementation WebPlayerTestsWebApp
@synthesize expectation = _expectation;
@synthesize fulfillingEvent = _fulfillingEvent;
@synthesize collectEvents = _collectEvents;
@synthesize collectedEvents = _collectedEvents;

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (BOOL)invokeCallback:(USRVInvocation *)invocation {
    return true;
}

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category params:(NSArray *)params {
    return true;
}

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... {
    NSLog(@"GOT_EVENT=%@", eventId);
    if (self.fulfillingEvent && [self.fulfillingEvent isEqualToString:eventId]) {
        NSLog(@"FULFILLING=%@", eventId);
        if (self.expectation) {
            [self.expectation fulfill];
        }
        else {
        }
    }
    
    if (self.collectEvents && [self.collectEvents isEqualToString:eventId]) {
        NSLog(@"COLLECTING=%@", eventId);
        if (!self.collectedEvents) {
            self.collectedEvents = [[NSMutableArray alloc] init];
        }
        
        long currentTimeMS = ([[NSDate date] timeIntervalSince1970] * 1000);
        [self.collectedEvents addObject:[NSNumber numberWithLong:currentTimeMS]];
    }
    
    return true;
}

- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className receiverClass:(NSString *)receiverClass callback:(NSString *)callback params:(NSArray *)params {
    return true;
}

@end


@interface WebPlayerTests : XCTestCase
@property (nonatomic, strong) UADSWebPlayerView *webPlayerView;
@property (nonatomic, strong) UADSViewController *viewController;
@end

@implementation WebPlayerTests
@synthesize webPlayerView = _webPlayerView;
@synthesize viewController = _viewController;

- (BOOL)waitForViewControllerStart {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    self.viewController = [[UADSViewController alloc] init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.viewController animated:true completion:^{
        [expectation fulfill];
    }];
    __block BOOL success = true;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
            if (error) {
                success = false;
            }
        }];
    });
    return success;
}

- (BOOL)waitForViewControllerExit {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    [self.viewController dismissViewControllerAnimated:true completion:^{
        [expectation fulfill];
    }];
    __block BOOL success = true;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
            if (error) {
                success = false;
            }
        }];
    });
    
    return success;
}

- (void)setUp {
    [super setUp];
    
    if ([USRVDevice isSimulator]) {
        NSLog(@"Device is simulator, Skipping setUp");
        return;
    }
    
    WebPlayerTestsWebApp *webViewApp = [[WebPlayerTestsWebApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    [self setWebPlayerView:[[UADSWebPlayerView alloc] initWithFrame:CGRectMake(0, 0, 400, 400) viewId:@"webplayer" webPlayerSettings:[UADSApiWebPlayer getWebPlayerSettings]]];
}

- (void)tearDown {
    [super tearDown];
    
    if ([USRVDevice isSimulator]) {
        NSLog(@"Device is simulator, Skipping tearDown");
        return;
    }

    [self.webPlayerView removeFromSuperview];
    self.webPlayerView = nil;
}

-(void) testCorrectUrl {
    if ([USRVDevice isSimulator]) {
        NSLog(@"Device is simulator, Skipping a web player test");
        return;
    }
    [self.webPlayerView setEventSettings:@{@"onPageFinished":@{@"sendEvent":@YES}, @"onPageStarted":@{@"sendEvent":@YES}, @"onReceivedError":@{@"sendEvent":@YES}}];
    
    XCTAssertTrue([self waitForViewControllerStart], @"Couldn't start viewController properly");
    [self.viewController.view addSubview:self.webPlayerView];
    
    XCTestExpectation *pageStartExpectation = [self expectationWithDescription:@"pageStartExpectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.webPlayerView loadUrl:[TestUtilities getTestServerAddress]];
    });
    
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setExpectation:pageStartExpectation];
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setFulfillingEvent:@"PAGE_STARTED"];
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    XCTAssertTrue(success, @"Page start expectation was not opened properly or an error occurred!");
    
    XCTestExpectation *pageFinishedExpectation = [self expectationWithDescription:@"pageFinishedExpectation"];
    
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setExpectation:pageFinishedExpectation];
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setFulfillingEvent:@"PAGE_FINISHED"];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    XCTAssertTrue(success, @"Page finished was not opened properly or an error occurred!");
    [self.webPlayerView removeFromSuperview];
    XCTAssertTrue([self waitForViewControllerExit], @"Couldn't exit viewController properly");
}

-(void) testIncorrectUrl {
    if ([USRVDevice isSimulator]) {
        NSLog(@"Device is simulator, Skipping a web player test");
        return;
    }
    [self.webPlayerView setEventSettings:@{@"onPageFinished":@{@"sendEvent":@YES}, @"onPageStarted":@{@"sendEvent":@YES}, @"onReceivedError":@{@"sendEvent":@YES}}];

    
    XCTAssertTrue([self waitForViewControllerStart], @"Couldn't start viewController properly");
    [self.viewController.view addSubview:self.webPlayerView];
    
    XCTestExpectation *pageStartExpectation = [self expectationWithDescription:@"pageStartExpectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.webPlayerView loadUrl:@"http://testing.wrong.url"];
    });
    
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setExpectation:pageStartExpectation];
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setFulfillingEvent:@"PAGE_STARTED"];
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    XCTAssertTrue(success, @"Page start expectation was not opened properly or an error occurred!");
    
    XCTestExpectation *errorExpectation = [self expectationWithDescription:@"errorExpectation"];
    
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setExpectation:errorExpectation];
    [(WebPlayerTestsWebApp *)[USRVWebViewApp getCurrentApp] setFulfillingEvent:@"ERROR"];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    XCTAssertTrue(success, @"Web player did not emit expected error event");
    [self.webPlayerView removeFromSuperview];
    XCTAssertTrue([self waitForViewControllerExit], @"Couldn't exit viewController properly");
}

@end
